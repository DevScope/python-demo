FROM linuxserver/code-server:4.14.0

RUN apt-get update -y && \
    apt-get install python3 python-is-python3 python3-pip -y

COPY . /config/workspace

WORKDIR /config/workspace

RUN pip install -r requirements.txt
