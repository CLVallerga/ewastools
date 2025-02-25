#' Infer the sex of sample donor
#' 
#' Return the normalized average total intensities of probes targeting the X and Y chromosomes. 
#' 
#' @rdname check_sex
#' @param raw Output of calling \code{\link{read_idats}}
#' @export
check_sex = function(raw){
	
 	if(!all(c('M','U','manifest')%in%names(raw))) stop('Invalid argument')

	with(raw,{

		# select allosomal probes
		chrX = manifest[chr=='X',index]
		chrY = manifest[chr=='Y',index]

		# compute the total intensities
		chrX = colMeans(M[chrX,,drop=FALSE]+U[chrX,,drop=FALSE],na.rm=TRUE)
		chrY = colMeans(M[chrY,,drop=FALSE]+U[chrY,,drop=FALSE],na.rm=TRUE)

		# compute the average total intensity across all autosomal probes
    	autosomes = manifest[!chr%in%c("X","Y"),index]
		autosomes = colMeans(M[autosomes,,drop=FALSE]+U[autosomes,,drop=FALSE],na.rm=TRUE)

		# normalize total intensities
		chrX = chrX/autosomes
		chrY = chrY/autosomes

		return(list(X=chrX,Y=chrY))
	})
}

#' @rdname check_sex
#' @param X,Y Forwarded from \code{check_sex}
#' @param male,female Indices of male and female samples
#' @return \code{check_sex} returns the normalized average total intensities of probes targeting the X and Y chromosomes. These are forwarded to \code{predict_sex} which returns a factor with levels "f","m" (and \code{NA} if the sex cannot be determined conclusively).
#' @export
predict_sex = function(X,Y,male,female){

	# compute the robust Hodges-Lehmann estimator for the total intensity for X chr probes
	cutX = outer(X[male],X[female],"+")
	cutX = median(cutX)/2

	# ... likewise for Y chr probes
	cutY = outer(Y[male],Y[female],"+")
	cutY = median(cutY)/2

	# Prediction based on in which quadrant (cutX/cutY) samples fall
	prediction = rep(NA,times=length(X))
	prediction[X>=cutX & Y<=cutY] =  "f"
	prediction[X<=cutX & Y>=cutY] =  "m"
	factor(prediction,levels=c("m","f"),labels=c("m","f"))
}