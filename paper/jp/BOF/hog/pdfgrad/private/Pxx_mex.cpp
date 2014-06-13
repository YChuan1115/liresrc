#include "mex.h"
#include "mkl_vml.h"
#include "mkl_cblas.h"
#include "mkl_service.h"
#include <omp.h>

/*
   K.D.E, W_ij = exp(-0.5*gamma*|x_i-x_j|^2)
 
   W = Pxx_mex(X, gamma);

  Input
   X     - Matrix    [dim x m, (single)]
   gamma - Parameter [1 x 1, (double)]

  Output:
   W - Probability Matrix [m x m, (single)]
*/

typedef ptrdiff_t intt;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
   if( nrhs != 2) mexErrMsgTxt("2 inputs are required.");
   if( nlhs != 1) mexErrMsgTxt("1 output is required.");
   
   float *X = (float*)mxGetPr(prhs[0]);
   intt dim = mxGetM(prhs[0]), m = mxGetN(prhs[0]);

   float gamma = (float)mxGetScalar(prhs[1]);
   
   /*- Init -*/
   int mkldy = mkl_get_dynamic();
   mkl_set_dynamic(1);

   // Distance matrix D=-gamma*0.5(x^2+y^2 - xy) //
   float *D = (float*)mxCalloc(m*m,sizeof(float));

   cblas_ssyrk(CblasColMajor,CblasUpper,CblasTrans,m,dim,gamma,X,dim,0.0,D,m);

   float *diagD = (float*)mxCalloc(m, sizeof(float));
   float *ones  = (float*)mxCalloc(m, sizeof(float));
   intt count = 0;
   for(int i = 0; i < m; i++){
	   ones[i]  = 1;
	   diagD[i] = 0.5*D[count];
	   count    += (m+1);
   }
   cblas_ssyr2(CblasColMajor,CblasUpper,m,-1,diagD,1,ones,1,D,m);
   mxFree(diagD);
   mxFree(ones);

   // W = exp(D) //
   mwSize odims[2]  = {m,m};
   plhs[0] = mxCreateNumericArray(2, odims, mxSINGLE_CLASS, mxREAL);
   float *W = (float*)mxGetPr( plhs[0] );
   vsExp(m*m, D, W);
   mxFree(D);

   mkl_set_dynamic(mkldy);
}
