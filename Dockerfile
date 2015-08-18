# Docker demo image, as used on try.jupyter.org and tmpnb.org

FROM danielballan/nsls2-minimal

MAINTAINER Daniel B Allan at Brookhaven National Lab <dallan@bnl.gov>
USER root

ENV http_proxy http://proxy:8888
ENV https_proxy http://proxy:8888

ADD notebooks/ /home/jovyan/
ADD datasets/ /home/jovyan/datasets/
RUN chown -R jovyan:jovyan /home/jovyan

EXPOSE 8888

USER jovyan
ENV HOME /home/jovyan
ENV SHELL /bin/bash
ENV USER jovyan
ENV PATH $CONDA_DIR/bin:$CONDA_DIR/envs/python2/bin:$PATH
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip
WORKDIR $HOME

USER jovyan

# Python packages
RUN conda install --yes numpy pandas scikit-learn scikit-image matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle dill numba bokeh && conda clean -yt

# Now for a python2 environment
#RUN conda create -p $CONDA_DIR/envs/python2 python=2.7 ipython numpy pandas scikit-learn scikit-image matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle dill numba bokeh && conda clean -yt
#RUN $CONDA_DIR/envs/python2/bin/python $CONDA_DIR/envs/python2/bin/ipython kernelspec install-self --user

# Get featured notebooks
# RUN mkdir /home/jovyan/featured
# RUN git clone --depth 1 https://github.com/jvns/pandas-cookbook.git /home/jovyan/featured/pandas-cookbook/

# download scikit-xray examples
RUN mkdir /home/jovyan/git && \
    cd git  && \
    git clone https://github.com/ericdill/scikit-xray-examples && \
    cd scikit-xray-examples && \
    git checkout update-examples && \
    cd demos && \
    # download the data
    python prepare_for_docker.py && \
    # move the demos to the notebooks directory
    rm prepare_for_docker.py
    cd ../
    mv demos /home/jovyan/scikit-xray-examples
    cd ../
    rm -rf scikit-xray-examples


# Convert notebooks to the current format
RUN find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
RUN find . -name '*.ipynb' -exec ipython trust {} \;

CMD ipython notebook
