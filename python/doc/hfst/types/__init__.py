## @package hfst.types
## implementation types


## An SFST transducer, unweighted.
SFST_TYPE = _libhfst.SFST_TYPE

## An OpenFst transducer with tropical weights.
TROPICAL_OPENFST_TYPE = _libhfst.TROPICAL_OPENFST_TYPE

## An OpenFst transducer with logarithmic weights (limited support).
LOG_OPENFST_TYPE = _libhfst.LOG_OPENFST_TYPE

## A foma transducer, unweighted.
FOMA_TYPE = _libhfst.FOMA_TYPE

## An HFST optimized lookup transducer, unweighted.
HFST_OL_TYPE = _libhfst.HFST_OL_TYPE

## An HFST optimized lookup transducer with weights.
HFST_OLW_TYPE = _libhfst.HFST_OLW_TYPE

## HFST2 header present, conversion required.
HFST2_TYPE = _libhfst.HFST2_TYPE

## Format left open by e.g. default constructor.
UNSPECIFIED_TYPE = _libhfst.UNSPECIFIED_TYPE

## Type not recognised. This type might be returned by a function if an error occurs.
ERROR_TYPE = _libhfst.ERROR_TYPE
