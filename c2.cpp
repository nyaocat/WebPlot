#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cstring>
#include <cmath>
#include <algorithm>
#include "plstream.h"

using namespace std;

class Sample{
public:
    Sample( int, const char ** );
  void plot();
  void set_colormap();
private:
  plstream *pls;
  PLFLT    **z;
  PLcGrid2 cgrid2;
};

Sample::Sample( int argc, const char ** argv ){
    pls = new plstream();
    pls->parseopts(&argc,argv,PL_PARSE_FULL);
    pls->scolbg(255, 255, 255);
    pls ->scol0(15, 0, 0, 0);
    // Initialize plplot
    pls->init();
}

void Sample::set_colormap(){
  //set color map
    PLFLT y[4]={-1.0,-1.0, 1.0, 1.0};
    PLFLT r[2]={0.0,1.0};
    PLFLT g[2]={0.0,0.0};
    PLFLT b[2]={1.0,0.0};
    PLFLT pos[2]={0.0,1.0};
    pls->scmap1l(true,2,pos,r,g,b,NULL);
}

void Sample::plot(){
    double xmin=0.0;
    double xmax=2.0;
    double ymin=0.0;
    double ymax=2.0;
    int ns = 201;
    int nx = 41;
    int ny = 41;
    // Allocate arrays
    PLFLT **z;
    pls->Alloc2dGrid(&z,nx,ny);
    PLcGrid2  cgrid2;//PLcGrid2  xg,yg,nx,ny
    pls->Alloc2dGrid(&cgrid2.xg,nx,ny);
    pls->Alloc2dGrid(&cgrid2.yg,nx,ny);
    cgrid2.nx=nx;
    cgrid2.ny=ny;
    {
      std::vector<double> zs;
      zs.reserve(nx * ny);
      std::ifstream ifs(getenv("F"));
      for(int i=0;i<nx;i++){
        for(int j=0;j<ny;j++){
          double x, y, z_;
          ifs >> x >> y >> z_;
          zs.push_back(z_);
          cgrid2.xg[i][j] = x;
          cgrid2.yg[i][j] = y;
          z[i][j]         = z_;
        }
      }
      const double zmax = *max_element(zs.begin(), zs.end());
      for(int i=0;i<nx;i++){
        for(int j=0;j<ny;j++){
          z[i][j]         = (z[i][j] / 0.007072 ) * 0.95;
        }
      }
    }


    //Set clevel
   PLFLT  *clevel = new PLFLT[ns];
   for(int i=0;i<ns;i++){
     clevel[i]=double(i) / ns;
    }
    //Plot
    pls->col0(15);
    pls->env(xmin,xmax,ymin,ymax,1,0);
    pls->lab(getenv("X"),getenv("Y"),getenv("TITLE"));

    int fill_width=2;
    int cont_color=0;
    int cont_width=0;
    pls->shades(z,nx,ny,NULL,xmin,xmax,ymin,ymax,clevel,ns,fill_width,cont_color,cont_width,plstream::fill,true,plstream::tr2,(void *) &cgrid2);
    //Free grid
    pls->Free2dGrid(cgrid2.xg,nx,ny);
    pls->Free2dGrid(cgrid2.yg,nx,ny);
    pls->Free2dGrid(z,nx,ny);

    delete pls;
}

int main( int argc, const char ** argv )
{
    Sample *x = new Sample( argc, argv );
    x->set_colormap();
    x->plot();
    delete x;
    return 0;
}
