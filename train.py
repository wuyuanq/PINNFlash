
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np
import os
from keras.utils.vis_utils import plot_model
from matplotlib import pyplot as plt
import globalData as gd
import PT_flash


NUM_PHASES = gd.NUM_PHASES
NUM_COMPONENTS = gd.NUM_COMPONENTS
NUM_SAMPLES = gd.NUM_SAMPLES
NUM_LAYERS = gd.NUM_LAYERS
NUM_NEURONS = gd.NUM_NEURONS
EPOCHS = gd.EPOCHS
BUFFER_SIZE = gd.BUFFER_SIZE
BATCH_SIZE = gd.BATCH_SIZE
PMIN = gd.PMIN
PMAX = gd.PMAX
TMIN = gd.TMIN
TMAX = gd.TMAX
sgDir = gd.sgDir
NNDir = gd.NNDir
sgFile = gd.sgFile
modelFile = gd.modelFile
weightFile = gd.weightFile
lossFile = gd.lossFile
lossPngFile = gd.lossPngFile
layerPngFile = gd.layerPngFile


loss_list = []
ia = np.zeros(NUM_COMPONENTS+1)
flash_dataset = [] # [P, T, x]


def gen_flash_ds_uniform(level):

    if(level == NUM_COMPONENTS+1):
        c_sum = 0.0
        for i in range(2, NUM_COMPONENTS+1):
            c_sum += 1.0/(NUM_SAMPLES[i]-1)*ia[i]
        if(c_sum <= 1.0):
            ta = np.zeros(NUM_COMPONENTS+2)
            ta[level] = 1.0 - c_sum
            for i in range(NUM_COMPONENTS+1):
                if(NUM_SAMPLES[i] > 1):
                    ta[i] = 1.0/(NUM_SAMPLES[i]-1)*ia[i]
                else:
                    ta[i] = 0.0
            flash_dataset.append(ta.tolist())
    else:
        for i in range(NUM_SAMPLES[level]):
            ia[level] = i
            gen_flash_ds_uniform(level+1)
            
            
def get_flash_ds_sg():

    ta = np.zeros(NUM_COMPONENTS+2)
    with open(sgFile, 'r') as f:
        i = 0
        while True:
            str = f.readline()
            if not str:
                break
            if(i%NUM_COMPONENTS == 0):
                ta[0] = float(str)
                ta[1] = 0.0
            for j in range(NUM_COMPONENTS-1):
                if(i%NUM_COMPONENTS == j+1):
                    ta[j+2] = float(str)
            if(i%NUM_COMPONENTS == NUM_COMPONENTS-1):
                c_sum = 0.0
                for j in range(NUM_COMPONENTS-1):
                    c_sum += ta[j+2]
                ta[NUM_COMPONENTS+1] = 1.0 - c_sum
                flash_dataset.append(ta.tolist())
            i = i + 1
            
            
def loss_fn(x_batch_train, prediction):
        
    P = x_batch_train[:,0]*(PMAX-PMIN)+PMIN
    T = x_batch_train[:,1]*(TMAX-TMIN)+TMIN
    x = x_batch_train[:,2:NUM_COMPONENTS+2]
    L = prediction[:,0]
    x_o_bsm = prediction[:,1:NUM_COMPONENTS+1]
    x_g_bsm = prediction[:,NUM_COMPONENTS+1:NUM_COMPONENTS*2+1]
    
    mask = tf.not_equal(x, 0.0)
    x_o = layers.Softmax()(x_o_bsm, mask)
    x_g = layers.Softmax()(x_g_bsm, mask)
    
    residual = PT_flash.PT_flash_residual(P, T, x, L, x_o, x_g, x_o_bsm, x_g_bsm)
    
    loss = tf.losses.mean_squared_error(0.0, residual)
    
    return loss
    
    
initializer = keras.initializers.HeNormal()
inputs = keras.Input(shape=(NUM_COMPONENTS+2,))
layer = layers.Dense(NUM_NEURONS, activation='relu', kernel_initializer=initializer, \
    kernel_regularizer=keras.regularizers.l2())(inputs)
for i in range(NUM_LAYERS-3):
    layer = layers.Dense(NUM_NEURONS, activation='relu', \
        kernel_initializer=initializer, kernel_regularizer=keras.regularizers.l2())(layer)
out_sigmoid = layers.Dense(1, activation='sigmoid')(layer)
out_relu1 = layers.Dense(NUM_COMPONENTS, activation='relu')(layer)
out_relu2 = layers.Dense(NUM_COMPONENTS, activation='relu')(layer)
outputs = tf.concat([out_sigmoid, out_relu1, out_relu2], axis=1)
model = keras.Model(inputs=inputs, outputs=outputs)
model.summary()
optimizer = keras.optimizers.Adam()

for epoch in range(EPOCHS):
    print("\nStart of epoch %d" % (epoch,))
    
    if(epoch == 0):
        gen_flash_ds_uniform(0)
    else:
        os.chdir(sgDir)
        os.system("make run -f Makefile.mac")
        os.chdir(NNDir)
        get_flash_ds_sg()
            
    train_dataset = tf.data.Dataset.from_tensor_slices(flash_dataset)
    train_dataset = train_dataset.shuffle(buffer_size=BUFFER_SIZE).batch(BATCH_SIZE)
    flash_dataset.clear()

    # Iterate over the batches of the dataset.
    for step, x_batch_train in enumerate(train_dataset):

        # Open a GradientTape to record the operations run
        # during the forward pass, which enables auto-differentiation.
        with tf.GradientTape() as tape:
            
            # Run the forward pass of the layer.
            # The operations that the layer applies
            # to its inputs are going to be recorded
            # on the GradientTape.
            prediction = model(x_batch_train, training=True)
            
            # Compute the loss value for this minibatch.
            loss = loss_fn(x_batch_train, prediction)
            loss_list.append(loss)

        # Use the gradient tape to automatically retrieve
        # the gradients of the trainable variables with respect to the loss.
        grads = tape.gradient(loss, model.trainable_weights)
        
        # Run one step of gradient descent by updating
        # the value of the variables to minimize the loss.
        optimizer.apply_gradients(zip(grads, model.trainable_weights))

        # Log every 10 batches.
        if(step%10 == 0):
            print(
                "Training loss (for one batch) at step %d: %.4f"
                % (step, float(loss))
            )
            print("Seen so far: %s samples" % ((step + 1) * BATCH_SIZE))

    if(os.path.exists(weightFile)):
        os.remove(weightFile)
    fwtxt = open(weightFile, 'a')
    for i in range(NUM_LAYERS+1):
        weights = model.layers[i+1].get_weights()
        for j in range(len(weights[0])):
            for k in range(len(weights[0][j])):
                fwtxt.write(str(weights[0][j][k])+'\n')
        for j in range(len(weights[1])):
            fwtxt.write(str(weights[1][j])+'\n')
    fwtxt.close()

model.save(modelFile)
plot_model(model, to_file=layerPngFile, show_shapes=True, show_layer_names=True)

loss_array=np.array(loss_list)
np.save(lossFile,loss_array)

fig = plt.figure()
plt.title("loss value")
plt.xlabel("minibatch")
plt.ylabel("loss")
plt.plot(loss_list)
plt.show()
fig.savefig(lossPngFile)
