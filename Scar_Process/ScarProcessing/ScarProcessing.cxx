#include "itkFixedArray.h"
#include "itkFlipImageFilter.h"
//#include "itkRGBPixel.h"
#include "itkImageFileReader.h"
#include "itkImage.h"
#include "itkMedianImageFilter.h"
//#include "itkSubtractImageFilter.h"
#include "itkResampleImageFilter.h"
#include "itkRecursiveGaussianImageFilter.h"
#include "itkIdentityTransform.h"
#include "itkIntensityWindowingImageFilter.h"

#include "vtkDataSetSurfaceFilter.h"
#include "itkImageToVTKImageFilter.h"
#include "vtkSmartPointer.h"
#include "vtkPolyData.h"
#include "vtkUnstructuredGrid.h"
#include "vtkSmoothPolyDataFilter.h"
#include "vtkPolyDataWriter.h"
#include "vtkThreshold.h"

int main(int argc, char * argv[] )
{

// ---Verify command line arguments---
    if( argc < 2 )
    {
        std::cerr << "Usage: " << std::endl;
        std::cerr << argv[0] << " InputImageFile OutputImageFile" << std::endl;
        return EXIT_FAILURE;
    }


// ---Declaring basic variables
    const unsigned int Dimension = 3;
    typedef float PixelType;
    typedef itk::Image<PixelType, Dimension>  ImageType;

    const char * inputFileName = argv[1];
    const char * outputFileName = argv[2];

// ---Reading input image---
    typedef itk::ImageFileReader<ImageType> ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

    reader->SetFileName( inputFileName );
    reader->Update();

// -----Initial filters--------------------------------------------------------------
// ---Flip Axes---
    typedef itk::FlipImageFilter <ImageType> FlipImageFilterType;
    FlipImageFilterType::Pointer flipFilter
    = FlipImageFilterType::New ();

    itk::FixedArray<bool, Dimension> flipAxes;
    flipAxes[0] = false;
    flipAxes[1] = false;
    flipAxes[2] = true;

    flipFilter->SetFlipAxes(flipAxes);
    flipFilter->SetInput(reader->GetOutput());
    flipFilter->Update();


// ---Median Filter---
    typedef itk::MedianImageFilter<ImageType, ImageType > FilterType;
    FilterType::Pointer medianFilter = FilterType::New();
    FilterType::InputSizeType radius;

    radius.Fill(2);
    medianFilter->SetRadius(radius);
    medianFilter->SetInput( flipFilter->GetOutput() );
    medianFilter->Update();



    /*
    typedef itk::SubtractImageFilter<ImageType> SubtractType;
    SubtractType::Pointer diff = SubtractType::New();
    diff->SetInput1(flipFilter->GetOutput());
    diff->SetInput2(medianFilter->GetOutput());
    diff->Update();
    */


// -----Isotropic resampling---------------------------------------------------
    typedef   double            InternalPixelType;
    typedef itk::Image<PixelType, Dimension>  InputImageType;
    typedef itk::Image< InternalPixelType, Dimension >   InternalImageType;

// ---Intensity windowing---
    typedef itk::IntensityWindowingImageFilter<
    ImageType,
    InternalImageType >  IntensityFilterType;
    IntensityFilterType::Pointer intensityWindowing = IntensityFilterType::New();
    intensityWindowing->SetWindowMinimum(0.0);
    intensityWindowing->SetWindowMaximum(150.0);
    intensityWindowing->SetOutputMinimum(   0.0 );
    intensityWindowing->SetOutputMaximum( 255.0 );
    intensityWindowing->SetInput( medianFilter->GetOutput() );

// ---Recursive Gaussian---
    typedef itk::RecursiveGaussianImageFilter<
    InternalImageType,
    InternalImageType > GaussianFilterType;

    GaussianFilterType::Pointer smootherX = GaussianFilterType::New();
    GaussianFilterType::Pointer smootherY = GaussianFilterType::New();
    smootherX->SetInput( intensityWindowing->GetOutput() );
    smootherY->SetInput( smootherX->GetOutput() );

    InputImageType::ConstPointer inputImage = medianFilter->GetOutput();
    const InputImageType::SpacingType& inputSpacing = inputImage->GetSpacing();

    const float isoSpacing = inputSpacing[0];
    smootherX->SetSigma( isoSpacing );
    smootherY->SetSigma( isoSpacing );

    smootherX->SetDirection( 0 );
    smootherY->SetDirection( 1 );

// ---Resample---
    typedef  unsigned char  OutputPixelType;
    typedef itk::Image< OutputPixelType,   Dimension >   OutputImageType;
    typedef itk::ResampleImageFilter<
    InternalImageType, OutputImageType >  ResampleFilterType;
    ResampleFilterType::Pointer resampler = ResampleFilterType::New();

// ---Identity transformation---
    typedef itk::IdentityTransform< double, Dimension >  TransformType;
    TransformType::Pointer transform = TransformType::New();
    transform->SetIdentity();
    resampler->SetTransform( transform );

// ---Linear interpolation---
    typedef itk::LinearInterpolateImageFunction<
    InternalImageType, double >  InterpolatorType;
    InterpolatorType::Pointer interpolator = InterpolatorType::New();
    resampler->SetInterpolator( interpolator );

    resampler->SetDefaultPixelValue( 255 ); // highlight regions without source

    OutputImageType::SpacingType spacing;
    spacing[0] = isoSpacing;
    spacing[1] = isoSpacing;
    spacing[2] = isoSpacing;
    resampler->SetOutputSpacing( spacing );

    resampler->SetOutputOrigin( inputImage->GetOrigin() );
    resampler->SetOutputDirection( inputImage->GetDirection() );

// ---Change size of image voxels---
    InputImageType::SizeType   inputSize =
    inputImage->GetLargestPossibleRegion().GetSize();
    typedef InputImageType::SizeType::SizeValueType SizeValueType;
    const double dx = inputSize[0] * inputSpacing[0] / isoSpacing;
    const double dy = inputSize[1] * inputSpacing[1] / isoSpacing;
    const double dz = (inputSize[2] - 1 ) * inputSpacing[2] / isoSpacing;

    InputImageType::SizeType   size;
    size[0] = static_cast<SizeValueType>( dx );
    size[1] = static_cast<SizeValueType>( dy );
    size[2] = static_cast<SizeValueType>( dz );
    resampler->SetSize( size );

    resampler->SetInput( smootherY->GetOutput() );
    resampler->Update();


// -----Moving to vtk object and adding filters--------------------------------
// ---ITK to VTK---
    typedef itk::ImageToVTKImageFilter<OutputImageType> ConnectorType;
    ConnectorType::Pointer connector = ConnectorType::New();

    connector->SetInput(resampler->GetOutput());
    connector->Update();

// ---Threshold---
    vtkSmartPointer<vtkThreshold> threshold =
    vtkSmartPointer<vtkThreshold>::New();

    int lowerThreshold = 50;
    int upperThreshold = 255;
    threshold->ThresholdBetween(lowerThreshold, upperThreshold);
    threshold->SetInputData(connector->GetOutput());
    threshold->Update();

// ---Extracting surface---
    vtkSmartPointer<vtkDataSetSurfaceFilter> surfaceFilter =
    vtkSmartPointer<vtkDataSetSurfaceFilter>::New();

    surfaceFilter->SetInputData(threshold->GetOutput());
    surfaceFilter->Update();

// ---Smoothing---
    vtkSmartPointer<vtkSmoothPolyDataFilter> smoothFilter =
    vtkSmartPointer<vtkSmoothPolyDataFilter>::New();

    smoothFilter->SetNumberOfIterations(600);
    smoothFilter->SetInputData(surfaceFilter->GetOutput());
    smoothFilter->Update();

// ---Writing polydata---
    vtkSmartPointer<vtkPolyDataWriter> vtkwriter =
    vtkSmartPointer<vtkPolyDataWriter> ::New();

    vtkwriter->SetFileName(outputFileName);
    vtkwriter->SetInputData(smoothFilter->GetOutput());
    vtkwriter->Write();

// ---Return---
    return EXIT_SUCCESS;

}
