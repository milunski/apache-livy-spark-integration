build-image:
	@docker build . -t livy-spark-matt:latest

launch-container:
	@docker run -p 8998:8998 -dit --name something livy-spark-matt

stop-container:
	@docker stop something