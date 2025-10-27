FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y fortune-mod cowsay netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/usr/games"

COPY wisecow.sh /app/wisecow.sh

RUN chmod +x /app/wisecow.sh

WORKDIR /app

EXPOSE 4499

CMD ["/app/wisecow.sh"]
