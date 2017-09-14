#!/usr/local/bin/python

import numpy as np
import sys,os
 
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
 
def writeplyfile(writefile,tet_nodes, tet_tot):
    """ Write triangularized mesh 0-indexed from input data 1-indexed"""
    in_size = tet_tot.shape
    # If only one triangle/quad
    if len(in_size)==1:
        if in_size[0]>0:
            tet_tot=tet_tot.reshapimport((1,in_size[0]))
             
    FILE=open(writefile,"w")
 
    FILE.write('ply \n')
    FILE.write('format ascii 1.0 \n')
    FILE.write('comment this is a surface \n')
    FILE.write('element vertex %i \n' % (tet_nodes.shape[0]) )
    FILE.write('property float x \n')
    FILE.write('property float y \n')
    FILE.write('property float z \n')
     
    FILE.write('element face %i \n' % (tet_tot.shape[0]) )
    FILE.write('property list uchar int vertex_index \n')
    FILE.write('end_header \n')
    # Nodes
    for i in range(len(tet_nodes)):
        x = tet_nodes[i,0]
        y = tet_nodes[i,1]
        z = tet_nodes[i,2]
         
        FILE.write('%f %f %f\n' % (x, y, z))
     
    # Faces NOTE: index from 0
    for i in range(len(tet_tot)):
        a1 = tet_tot[i,0]-1
        a2 = tet_tot[i,1]-1
        a3 = tet_tot[i,2]-1
         
        if in_size[1]==3:
            FILE.write('3 %i %i %i\n' % (a1,a2,a3))
        elif in_size[1]==4:
            a4 = tet_tot[i,3]-1
            FILE.write('4 %i %i %i %i\n' % (a1,a2,a3,a4))
     
    FILE.close()
    return
 
def make_triangle_connection(patch):
    n_strips = patch["height"]-1
    n_in_strip = patch["width"]
    tris = np.zeros((n_strips*n_in_strip*2,3))
 
    for i in xrange(n_in_strip):
        for j in xrange(n_strips):
            i00=i+n_in_strip*j
            i01=i+n_in_strip*(1+j)
            i11=(i+1)%n_in_strip+n_in_strip*(1+j)
            i10=(i+1)%n_in_strip+n_in_strip*j
 
            tris[2*i+j*n_in_strip*2,:] = [i00,i01,i11]
            tris[2*i+1+j*n_in_strip*2,:] = [i00,i11,i10]
     
    return tris
 
def cover_apex(nodes_renum, tris, patch,principal_axis=0):
    nodes_covered = np.zeros((len(nodes_renum)+1,3))
    n_in_strip = patch["width"]
    tris_covered = np.zeros((len(tris)+n_in_strip,3))
     
     
    # Assume apex has largest principal axis coordinate
    p_coor = np.mean(nodes_renum[:patch["width"],:],axis=0)
    p_coor[principal_axis] += .0
    nodes_covered[1:,:] = nodes_renum
    nodes_covered[0,:] = p_coor
    tris_covered[n_in_strip:,:]=tris+1
    for i in xrange(n_in_strip):
        tris_covered[i,:] = [0,i+1,(i+1)%n_in_strip+1]
 
     
    return nodes_covered, tris_covered
 
def calculate_normals(points,faces,node_id=None):
    """ Calculate unit length normals of triangle faces or one point"""
    face_normals=np.cross( points[faces[:,1],:]-points[faces[:,0],:],
                           points[faces[:,2],:]-points[faces[:,0],:] )
 
    if node_id is None:
        #face_normals /= np.sqrt((face_normals ** 2).sum(-1))[..., np.newaxis]
        return face_normals
    else:
        ix,iy=np.where(faces==node_id)
        face_normal_at_node = np.sum(face_normals[ix,:],axis=0)
        normal_length = np.sqrt((face_normal_at_node ** 2).sum(-1))#[..., np.newaxis]
        if normal_length != 0.0:
            face_normal_at_node /= normal_length
         
        return face_normal_at_node
 
# Smoothing of surfaces by gamer
def smooth_gamer(vertices_in,faces_in,user_params=None):
    import gamer as gamer # For optimizing surface. Must be installed.
     
 
    if not user_params:
        user_params={"preserve_ridges":0,"max_iter":10,"min_max_angle":150,
                     "max_min_angle":15,"rate":1.8,"numiter":4}
 
    gmesh = gamer.SurfaceMesh(len(vertices_in),\
                              len(faces_in))
 
    for i, bverts in enumerate(vertices_in):
        gvert = gmesh.vertex(i)
        gvert.x, gvert.y, gvert.z = tuple(bverts)
        gvert.sel=True
     
     
    for i, bface in enumerate(faces_in):
        gface = gmesh.face(i)
        gface.a, gface.b, gface.c = tuple(map(int,bface))
        gface.sel=True
        #gmesh.vertex(gface.a).sel=True
        #gmesh.vertex(gface.b).sel=True
        #gmesh.vertex(gface.c).sel=True
     
    #getattr(gmesh,"refine")()
    getattr(gmesh,"smooth")(preserve_ridges=user_params["preserve_ridges"],
                            max_iter=user_params["max_iter"],
                            min_max_angle=user_params["min_max_angle"],
                            max_min_angle=user_params["max_min_angle"]) 
    getattr(gmesh,"coarse_dense")(rate=user_params["rate"],
                                  numiter=user_params["numiter"])
    getattr(gmesh,"smooth")(preserve_ridges=user_params["preserve_ridges"],
                            max_iter=user_params["max_iter"],
                            min_max_angle=user_params["min_max_angle"],
                            max_min_angle=user_params["max_min_angle"])
    getattr(gmesh,"normal_smooth")() 
    getattr(gmesh,"smooth")(preserve_ridges=user_params["preserve_ridges"],
                            max_iter=user_params["max_iter"],
                            min_max_angle=user_params["min_max_angle"],
                            max_min_angle=user_params["max_min_angle"])
     
    vertices_out = np.asarray([(gvert.x, gvert.y, gvert.z) for gvert in gmesh.vertices()])
    faces_out = np.asarray([(gface.a, gface.b, gface.c) for gface in gmesh.faces()])
    return vertices_out,faces_out
 
 
if __name__=="__main__":
     
    if len(sys.argv)==2:
        filename_input = sys.argv[1]
        print "Making surface for",filename_input
    else:
        filename_input="ARVC004-LVEndo-Frame_1.txt"
        print "Usage: "+sys.argv[0]+" filename_input"
        print "Defaults to",filename_input
 
    file_namebase, file_extension = os.path.splitext(filename_input)
    filename_output = ".".join([file_namebase,"ply"])
 
    user_input = {"print_ply":True,
                  "principal_axis":2, 
                  "reshuffle_point_order":True,
                  "cover_apex":True,
                  "gamer_smooth":False,
                  "plot":False}
     
    gamer_user_params = {"preserve_ridges":0,"max_iter":6,#maxiter=10 or 3
                         "min_max_angle":150,"max_min_angle":15,
                         "rate":1.6,"numiter":1}#rate 1.6,numiter 4
 
    points0=np.loadtxt(filename_input)
 
    # Reshuffle point order
    if user_input["reshuffle_point_order"]:
        points = points0[::-1,:]
    else:
        points = points0
 
    principal_axis = user_input["principal_axis"]
    slice_position_test = points[0,principal_axis]
    n_per_slice = np.sum(points[:,principal_axis]==slice_position_test)
    n_slices = int(len(points)/n_per_slice)
 
    # Testing input data
    if not n_slices*n_per_slice == len(points):
        print "OOPS: Not same number of points per slice!!! (Exit program)"
        sys.exit()
 
    # Make triangle surface
    patch={"height":n_slices,"width":n_per_slice}
    tris = make_triangle_connection(patch)
 
    # Cover apex hole
    if user_input["cover_apex"]:
        nodes_final, tris_final = cover_apex(points, tris, patch,principal_axis=principal_axis)
    else:
        nodes_final = points
        tris_final = tris
     
     
    # Check data for degenerate tris
    normals= calculate_normals(nodes_final,tris_final.astype(int),node_id=None)
    err_tol = 0.000001
     
    # Removes duplicate indices (unfinished) 
    bad_tris = np.where(np.abs(np.sqrt((normals ** 2).sum(-1)))<err_tol)[0]
    bad_indices = tris_final[bad_tris,:].astype(int).flatten()
    nodes_to_check = nodes_final[bad_indices,:]
    new_indices = bad_indices.copy()
    for i in range(len(bad_indices)-1):
        for j in range(i+1,len(bad_indices)):
            this_dist = np.sqrt(np.sum((nodes_to_check[i,:]-nodes_to_check[j,:])**2))
            if this_dist<err_tol:
                new_indices[j] = new_indices[i]
     
    #tris_final[bad_tris,:] = new_indices.reshape((len(bad_indices)/3,3))
    #nodes_final[bad_indices,:] = nodes_final[new_indices,:]
     
    good_tris = np.where(np.abs(np.sqrt((normals ** 2).sum(-1)))>err_tol)[0]
     
    # Remove bad tris
    tris_final = tris_final[good_tris,:]
 
    # Remove bad nodes
    tris_final_temp = tris_final.flatten()
    for i in xrange(tris_final.size):
        node_i = tris_final_temp[i]
        if node_i in bad_indices:
            if node_i not in new_indices:
                indice_i = np.where(node_i == bad_indices)[0][0]
                tris_final_temp[i] = new_indices[indice_i]
    tris_final = tris_final_temp.reshape(tris_final.shape)
    # Smooth surface by gamer
    if user_input["gamer_smooth"]:
        nodes_final,tris_final = smooth_gamer(nodes_final,tris_final,user_params=gamer_user_params)
 
    # Write .ply-file
    if user_input["print_ply"]:
        print "Printing:",filename_output
        writeplyfile(filename_output,nodes_final, tris_final+1)
 
    # Plot data
    if user_input["plot"]:
        fig, ax = plt.subplots(ncols=1, subplot_kw=dict(projection='3d'))
        ax.scatter3D(nodes_final[:,0],nodes_final[:,1],nodes_final[:,2],c='r')
        ax.scatter3D(points0[:,0],points0[:,1],points0[:,2],c='b')
        fig.show()
