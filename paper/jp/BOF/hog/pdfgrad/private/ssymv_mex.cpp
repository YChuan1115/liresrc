#include "mex.h"
#include "mkl_cblas.h"
#include "mkl_service.h"
#include <omp.h>

/*
  Matrix-vector multiplication for symmetric matrix, C=b*A

   C = ssymv_mex(A, b);

  Input
   A - Symmetric Matrix (upper) [m x m, (single)]
   b - Vector [1 x m, (single)]

  Output:
   C - Vector [1 x m, (single)]
*/

typedef ptrdiff_t intt;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
   if( nrhs != 2) mexErrMsgTxt("2 inputs are required.");
   if( nlhs != 1) mexErrMsgTxt("1 output is required.");

   intt m = mxGetM(prhs[0]);
  
   float *A = (float*)mxGetPr(prhs[0]);
   float *b = (float*)mxGetPr(prhs[1]);
   
   mwSize odims[2]  = {1,m};
   plhs[0] = mxCreateNumericArray(2, odims, mxSINGLE_CLASS, mxREAL);
   float *C = (float*)mxGetPr( plhs[0] );

   int mkldy = mkl_get_dynamic();
   mkl_set_dynamic(1);

   cblas_ssymv(CblasColMajor,CblasUpper,m,1.0,A,m,b,1,0.0,C,1);

   mkl_set_dynamic(mkldy);
}
