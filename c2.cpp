#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cstring>
#include <cmath>
#include <algorithm>
#include <vector>
#include <string>
#include "plstream.h"

using namespace std;

vector<string> split(const string &str, char delim){
  vector<string> res;
  size_t current = 0, found;
  while((found = str.find_first_of(delim, current)) != string::npos){
    res.push_back(string(str, current, found - current));
    current = found + 1;
  }
  res.push_back(string(str, current, str.size() - current));
  return res;
}
std::string basename(const std::string& path) {
    return path.substr(path.find_last_of('/') + 1);
}
void plot( int argc, const char ** argv, char const* device, char const* inpath, char const* outpath)
{
  plstream *pls;
  PLFLT    **z;
  PLcGrid2 cgrid2;

  pls = new plstream();
  pls->sdev(device);
  pls->sfnam(outpath);
  pls->parseopts(&argc,argv,PL_PARSE_FULL);
  pls->scolbg(255, 255, 255);
  pls ->scol0(15, 0, 0, 0);
  // Initialize plplot
  pls->init();

  {
    //set color map
    PLFLT y[4]={-1.0,-1.0, 1.0, 1.0};
    PLFLT r[2]={0.0,1.0};
    PLFLT g[2]={0.0,0.0};
    PLFLT b[2]={1.0,0.0};
    PLFLT pos[2]={0.0,1.0};
    pls->scmap1l(true,2,pos,r,g,b,NULL);
  }
  { // plot
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
      std::ifstream ifs(inpath);
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
}


int main( int argc, const char ** argv )
{
    std::vector<string> const fs = split(getenv("F"), ',');

    for (std::vector<string>::const_iterator it = fs.begin(); it != fs.end(); ++it)
    {
      std::string const& f = *it;
      std::string const outpath = ("public/images/"+basename(f)+".png");
      plot( argc, argv, getenv("D"), f.c_str(), outpath.c_str());
      std::cout << outpath << ",";
    }

    return 0;
}
