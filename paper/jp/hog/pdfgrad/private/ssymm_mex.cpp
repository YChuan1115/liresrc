#include "mex.h"
#include "mkl_cblas.h"
#include "mkl_service.h"
#include <omp.h>

/*
  Matrix-matrix multiplication for symmetric matrix, C=B*A

   C = ssymm_mex(A, B);

  Input
   A - Symmetric Matrix (upper) [m x m, (single)]
   B - Matrix [n x m, (single)]

  Output:
   C - matrix [n x m, (single)]
*/

typedef ptrdiff_t intt;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
   if( nrhs != 2) mexErrMsgTxt("2 inputs are required.");
   if( nlhs != 1) mexErrMsgTxt("1 output is required.");
  
   float *A = (float*)mxGetPr(prhs[0]);
   float *B = (float*)mxGetPr(prhs[1]);
   intt m = mxGetM(prhs[0]);
   intt n = mxGetM(prhs[1]);
   
   mwSize odims[2]  = {n,m};
   plhs[0] = mxCreateNumericArray(2, odims, mxSINGLE_CLASS, mxREAL);
   float *C = (float*)mxGetPr( plhs[0] );

   int mkldy = mkl_get_dynamic();
   mkl_set_dynamic(1);

   cblas_ssymm(CblasColMajor,CblasRight,CblasUpper,n,m,1.0,A,m,B,n,0.0,C,n);

   mkl_set_dynamic(mkldy);
}
