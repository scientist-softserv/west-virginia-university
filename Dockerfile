FROM ruby:2.7.7

ENV BUNDLER_VERSION=2.4.7
ENV NODE_VERSION=18
ENV RAILS_VERSION=5.2.8.1
# should match local folder of our application
ENV PROJECT_PATH hydra
ENV TZ="America/New_York"

RUN mkdir -p /home/${PROJECT_PATH}/
WORKDIR /home/${PROJECT_PATH}
ADD ./${PROJECT_PATH} /home/${PROJECT_PATH}

RUN apt-get update && apt-get -y install cron postgresql-client

# Use JEMALLOC instead
# JEMalloc is a faster garbage collection for Ruby.
# -------------------------------------------------------------------------------------------------
RUN apt-get install -y libjemalloc2
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# increase ImageMagick's memory limit
RUN sed -i -E 's/name="disk" value=".+"/name="disk" value="4GiB"/g' /etc/ImageMagick-6/policy.xml
# Modifiy ImageMagick's security policy to allow reading and writing PDFs
RUN sed -i 's/policy domain="coder" rights="none" pattern="PDF"/policy domain="coder" rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml

RUN \
  gem update --system --quiet && \
  gem install bundler -v ${BUNDLER_VERSION} && \
  gem install rails -v ${RAILS_VERSION} && \
  bundle install --jobs=4 --retry=3 

# Node.js
# -------------------------------------------------------------------------------------------------
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
	&& apt-get -y install nodejs
