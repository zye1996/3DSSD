# evaluation 
TFPATH=$1 # e.g: /usr/local/lib/python3.5/dist-packages/tensorflow
CUDAPATH=$2 # e.g: /usr/local/cuda-9.0
OPSPATH="lib/utils/tf_ops"
TF_INC=$(python -c 'import tensorflow as tf; print(tf.sysconfig.get_include())')
TF_LFLAGS=$(python -c 'import tensorflow as tf; print(" ".join(tf.sysconfig.get_link_flags()))')

# voxel operation
cd lib/builder/voxel_generator
./build.sh
cd dist
pip install points2voxel-0.0.1-cp37-cp37m-linux_x86_64.whl
cd ../../../..

# evaluation
cd ${OPSPATH}/evaluation
/usr/bin/gcc -std=c++11 tf_evaluate.cpp -o tf_evaluate_so.so -shared -fPIC -I $TF_INC -I ${CUDAPATH}/include -I $TF_INC/external/nsync/public -lcudart -L ${CUDAPATH}/lib64/ $TF_LFLAGS -O2 -D_GLIBCXX_USE_CXX11_ABI=1
cd ..

# grouping
cd grouping
$CUDAPATH/bin/nvcc  -ccbin /usr/bin/gcc tf_grouping_g.cu -o tf_grouping_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc -std=c++11 tf_grouping.cpp tf_grouping_g.cu.o -o tf_grouping_so.so -shared -fPIC -I $TF_INC -I $CUDAPATH/include -I $TF_INC/external/nsync/public -lcudart -L $CUDAPATH/lib64/  $TF_LFLAGS -O2 -D_GLIBCXX_USE_CXX11_ABI=1
cd ..

# interpolation
cd interpolation
$CUDAPATH/bin/nvcc -ccbin /usr/bin/gcc tf_interpolate_g.cu -o tf_interpolate_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc -std=c++11 tf_interpolate.cpp tf_interpolate_g.cu.o -o tf_interpolate_so.so -shared -fPIC -I $TF_INC -I $CUDAPATH/include -I $TF_INC/external/nsync/public -lcudart -L $CUDAPATH/lib64/ $TF_LFLAGS -O2 -D_GLIBCXX_USE_CXX11_ABI=1
cd ..

# points pooling
cd points_pooling
$CUDAPATH/bin/nvcc -ccbin /usr/bin/gcc tf_points_pooling_g.cu -o tf_points_pooling_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc -std=c++11 tf_points_pooling.cpp tf_points_pooling_g.cu.o -o tf_points_pooling_so.so -shared -fPIC -I $TF_INC -I $CUDAPATH/include -I $TF_INC/external/nsync/public -lcudart -L $CUDAPATH/lib64/ $TF_LFLAGS -O2 -D_GLIBCXX_USE_CXX11_ABI=1
cd ..

# sampling
cd sampling
$CUDAPATH/bin/nvcc -ccbin /usr/bin/gcc tf_sampling_g.cu -o tf_sampling_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc -std=c++11 tf_sampling.cpp tf_sampling_g.cu.o -o tf_sampling_so.so -shared -fPIC -I $TF_INC -I $CUDAPATH/include -I $TF_INC/external/nsync/public -lcudart -L $CUDAPATH/lib64/ $TF_LFLAGS -O2 -D_GLIBCXX_USE_CXX11_ABI=1
cd ..

# nms
cd nms
./build.sh
cd ..

