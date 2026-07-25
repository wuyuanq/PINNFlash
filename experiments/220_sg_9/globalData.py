
NUM_PHASES = 2
NUM_COMPONENTS = 2
NUM_SAMPLES = [31, 1, 51]
NUM_LAYERS = 6
NUM_NEURONS = 20
EPOCHS = 20
BUFFER_SIZE = 1024
BATCH_SIZE = 128
PMIN = 1.9e6 # Pa
PMAX = 2.1e6
TMIN = 2.2e2 # K
TMAX = 2.2e2
TESTTEM = 2.2e2
F = 1.0
R = 8.314
THRESHOLD = 0.1

# 0 is CH4, and 1 is C3H8
Tc = [1.9e2, 3.7e2]
Pc = [4.6e6, 4.2e6]
omega = [0.01, 0.15]
delta = [[0, 0.036],
         [0.036, 0]]

trueDataPath = "./GenerateTrueFlashData_2c/trueData/"
sgDir = "/Users/yuanqingwu/research/SparseGrids/sg_general"
NNDir = "/Users/yuanqingwu/research/DeepLearning"
sgFile = "/Users/yuanqingwu/Research/SparseGrids/sg_general/Case4/sg/union.txt"
modelFile = "flash_model.tf"
weightFile = "weights.txt"
lossFile = "loss.npy"
lossPngFile = "loss.png"
layerPngFile = "layers_plot.png"
