
import tensorflow as tf
import numpy as np
import math
import globalData as gd


NUM_COMPONENTS = gd.NUM_COMPONENTS
F = gd.F
R = gd.R
THRESHOLD = gd.THRESHOLD
Tc = gd.Tc
Pc = gd.Pc
omega = gd.omega
delta = gd.delta


def PREOS(P, T, x_o, x_g):
    
    lambda1 = []
    for i in range(NUM_COMPONENTS):
        lambda1.append(0.37464 + 1.5423*omega[i] - 0.26992*omega[i]**2)
        
    alpha = []
    for i in range(NUM_COMPONENTS):
        alpha.append((1.0+lambda1[i]*(1.0-math.sqrt(T/Tc[i])))**2)
    
    am = []
    bm = []
    for i in range(NUM_COMPONENTS):
        am.append(0.45724*alpha[i]*R**2*Tc[i]**2/Pc[i])
        bm.append(0.077796*R*Tc[i]/Pc[i])
           
    ao = 0.0
    for i in range(NUM_COMPONENTS):
        for j in range(NUM_COMPONENTS):
            ao = ao + x_o[i]*x_o[j]*(1.0-delta[i][j])*math.sqrt(am[i]*am[j])
        
    ag = 0.0
    for i in range(NUM_COMPONENTS):
        for j in range(NUM_COMPONENTS):
            ag = ag + x_g[i]*x_g[j]*(1.0-delta[i][j])*math.sqrt(am[i]*am[j])
       
    bo = 0.0
    for i in range(NUM_COMPONENTS):
        bo = bo + x_o[i]*bm[i]
        
    bg = 0.0
    for i in range(NUM_COMPONENTS):
        bg = bg + x_g[i]*bm[i]
        
    # compute liquid phase
    AO = ao*P/(R*T)**2
    BO = bo*P/(R*T)

    Z = np.roots([1.0, -(1.0-BO), (AO-3.0*BO**2-2.0*BO), -(AO*BO-BO**2-BO**3)])

    ZRP = []
    for i in range(3):
        if(np.isreal(Z[i]) and (Z[i]>BO)):
            ZRP.append(Z[i])

    ZO = min(ZRP)
    if(np.size(ZO) == 0):
        raise ValueError("ZO doesn''t have a reasonable value.")
    
    # compute gas phase
    AG = ag*P/(R*T)**2
    BG = bg*P/(R*T)
    
    Z = np.roots([1.0, -(1.0-BG), (AG-3.0*BG**2-2.0*BG), -(AG*BG-BG**2-BG**3)])
    
    ZR = []
    for i in range(3):
        if(np.isreal(Z[i])):
            ZR.append(Z[i])

    ZG = max(ZR)
    if(np.size(ZG) == 0):
        raise ValueError("ZG doesn''t have a reasonable value.")
        
    return am, bm, ao, ag, bo, bg, AO, BO, AG, BG, ZO, ZG
      
      
def fugacity_coef(P, T, x_o, x_g):

    [am, bm, ao, ag, bo, bg, AO, BO, AG, BG, ZO, ZG] = PREOS(P, T, x_o, x_g)

    phi_o = []
    phi_g = []

    for i in range(NUM_COMPONENTS):
    
        CO = 0.0
        for j in range(NUM_COMPONENTS):
            CO = CO + x_o[j]*(1-delta[i][j])*math.sqrt(am[i]*am[j])
        if(ao != 0):
            CO = CO * 2.0/ao
            phi_o.append(math.exp(bm[i]/bo*(ZO-1.0)-math.log(ZO-BO) - AO/(2.0*math.sqrt(2.0)* \
                BO)*(CO-bm[i]/bo)*math.log((ZO+2.414*BO)/(ZO-0.414*BO))))

        CG = 0.0
        for j in range(NUM_COMPONENTS):
            CG = CG + x_g[j]*(1.0-delta[i][j])*math.sqrt(am[i]*am[j])
        if(ag != 0):
            CG = CG * 2.0/ag
            phi_g.append(math.exp(bm[i]/bg*(ZG-1.0)-math.log(ZG-BG) - AG/(2.0*math.sqrt(2.0)* \
                BG)*(CG-bm[i]/bg)*math.log((ZG+2.414*BG)/(ZG-0.414*BG))))
        
    return phi_o, phi_g
    
    
def PT_flash_residual(P, T, x, L, x_o, x_g, x_o_bsm, x_g_bsm):
    
    residual = []

    for i in range(P.shape[0]):
    
        for j in range(NUM_COMPONENTS):
            if(x[i,j] > 0):
                #residual.append(tf.abs(tf.math.log((x_o[i,j]*L[i]+x_g[i,j]*(F-L[i]))/(x[i,j]*F))))
                residual.append(tf.abs(x_o[i,j]*L[i] + x_g[i,j]*(F-L[i]) - x[i,j]*F))
            else:
                residual.append(tf.math.sqrt(x_o_bsm[i,j]**2))
                residual.append(tf.math.sqrt(x_g_bsm[i,j]**2))

        [phi_o, phi_g] = fugacity_coef(P[i], T[i], x_o[i], x_g[i])
        
        if(L[i] > 1.0-THRESHOLD):
            res2W = 1.0 - L[i]
        elif(L[i] < THRESHOLD):
            res2W = L[i]
        
        for j in range(NUM_COMPONENTS):
            if(x[i,j] > 0):
                if(L[i] > 1.0-THRESHOLD):
                    residual.append(tf.abs(tf.math.log((x_o[i,j]*phi_o[j])/(x_g[i,j]*phi_g[j])))*res2W + \
                    (tf.math.sqrt((x_o[i,j]-x[i,j])**2+x_g[i,j]**2))*(1.0-res2W))
                elif(L[i] < THRESHOLD):
                    residual.append(tf.abs(tf.math.log((x_o[i,j]*phi_o[j])/(x_g[i,j]*phi_g[j])))*res2W + \
                    (tf.math.sqrt((x_g[i,j]-x[i,j])**2+x_o[i,j]**2))*(1.0-res2W))
                else:
                    residual.append(tf.abs(tf.math.log((x_o[i,j]*phi_o[j])/(x_g[i,j]*phi_g[j]))))
            
    return residual

