FROM ruby:2.7.7

ENV BUNDLER_VERSION=2.2.27
ENV NODE_VERSION=18
ENV RAILS_VERSION=5.2.6
# should match local folder of our application
ENV PROJECT_PATH hydra

RUN mkdir -p /home/${PROJECT_PATH}/
WORKDIR /home/${PROJECT_PATH}
ADD ./${PROJECT_PATH} /home/${PROJECT_PATH}

RUN apt-get update && apt-get -y install cron postgresql-client

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Use JEMALLOC instead
# JEMalloc is a faster garbage collection for Ruby.
# -------------------------------------------------------------------------------------------------
RUN apt-get install -y libjemalloc2 libjemalloc-dev
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so

RUN \
  gem update --system --quiet && \
  gem install bundler -v ${BUNDLER_VERSION} && \
  gem install rails -v ${RAILS_VERSION} && \
  bundle install --jobs=4 --retry=3

# Node.js
# -------------------------------------------------------------------------------------------------
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs
