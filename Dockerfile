# The existing docker image should be deployable on binder - we just need
# to copy the content across to the $HOME directory ... see
# https://mybinder.readthedocs.io/en/latest/dockerfile.html#when-should-you-use-a-dockerfile
# for details

# SHA tagging of the publication version
FROM underworldcode/underworld2@sha256:9eb117b9332b039887ef2e2f428dc08cfb8a36af9c2f78acaa8ef1d65a1f7864

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

# tidy up

USER root
WORKDIR /home/jovyan

## A requirement of binder (but can it be dropped ?)
RUN pip install --no-cache-dir --upgrade notebook==5.*

RUN mv /workspace/publications /home/jovyan/publications
RUN mv /workspace/user_guide /home/jovyan/user_guide
RUN mv /workspace/tutorials /home/jovyan/tutorials
## RUN mv /workspace /home/jovyan/.scratch || true

## This is not used by binder at present (but for testing, it is helpful to have
## the notebook launched by default (but we hide this file !)

RUN echo "1"
ADD run-jupyter.sh /home/jovyan/.run-jupyter.sh
ADD Index.ipynb /home/jovyan/Index.ipynb

## Set config options ??
RUN rm -rf .jupyter || true
RUN mkdir  .jupyter
ADD jupyter_notebook_config.py .jupyter/jupyter_notebook_config.py


RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}

ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD /home/jovyan/.run-jupyter.sh
