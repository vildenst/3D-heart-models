#include <vtkSmartPointer.h>
#include <vtkPolyData.h>
#include <vtkPolyDataWriter.h>
#include <vtkPLYReader.h>
#include <vtkPLYWriter.h>
#include <vtkSmoothPolyDataFilter.h>
#include <vtkWindowedSincPolyDataFilter.h>
#include <vtkPolyDataNormals.h>

int main(int argc, char *argv[])
{
    if(argc < 3)
    {
        std::cerr << "Required arguments: input.ply output.vtk" << std::endl;
        return EXIT_FAILURE;
    }

    std::string inputFileName = argv[1];
    std::string outputFileName = argv[2];
    //std::string outputFileNamePLY = argv[3];

    // Read in PLY file
    vtkSmartPointer<vtkPLYReader> reader = vtkSmartPointer<vtkPLYReader>::New();
    reader->SetFileName(inputFileName.c_str());
    reader->Update();

    // Smooth the mesh
    vtkSmartPointer<vtkSmoothPolyDataFilter> smoother = vtkSmartPointer<vtkSmoothPolyDataFilter>::New();
    smoother->SetInputData(reader->GetOutput());
    smoother->SetRelaxationFactor(0.02);
    smoother->SetNumberOfIterations(400);
    smoother->BoundarySmoothingOn();
    smoother->Update();

    // Generate surface normals
    vtkSmartPointer<vtkPolyDataNormals> normals = vtkSmartPointer<vtkPolyDataNormals>::New();
    normals->SetInputData(smoother->GetOutput());
    normals->FlipNormalsOn();
    normals->Update();

    // Write out to VTK
    vtkSmartPointer<vtkPolyDataWriter> writer = vtkSmartPointer<vtkPolyDataWriter>::New();
    writer->SetFileName(outputFileName.c_str());
    writer->SetInputData(normals->GetOutput());
    writer->Update();

    /* Write smoothed to PLY
    vtkSmartPointer<vtkPLYWriter> writerPLY = vtkSmartPointer<vtkPLYWriter>::New();
    writerPLY->SetFileName(outputFileNamePLY.c_str());
    writerPLY->SetInputConnection(normals->GetOutputPort());
    writerPLY->Update();
    */

    return EXIT_SUCCESS;
}
