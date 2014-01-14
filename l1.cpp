#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cstring>
#include <cmath>
#include <algorithm>
#include <vector>
#include <set>
#include <string>
#include "plstream.h"

// std::ofstream ofs("dbg");


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

struct DataOpts
{
  int nummax;
  double xmin;
  double xmax;
  double ymin;
  double ymax;
};

DataOpts filecheck(std::vector<string> const& fs)
{
  DataOpts opts = {0, 0, 0, 0, 0};

  for (std::vector<string>::const_iterator it = fs.begin(); it != fs.end(); ++it)
  {
    std::string const& f = *it;

    std::ifstream ifs(f.c_str());
    int num;
    while (ifs)
    {
      double x, y;
      ifs >> x >> y;

      opts.xmin = std::min(opts.xmin, x);
      opts.ymin = std::min(opts.ymin, y);
      opts.xmax = std::max(opts.xmax, x);
      opts.ymax = std::max(opts.ymax, y);
      ++num;
    }
    opts.nummax = std::max(opts.nummax, num);
  }
  return opts;
}

void plot( int argc, const char ** argv, char const* device, char const* inpath, char const* outpath, DataOpts const& opts)
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
    double xmin=opts.xmin;
    double xmax=opts.xmax;
    double ymin=opts.ymin;
    double ymax=opts.ymax;
    std::vector<double> ax; ax.reserve(opts.nummax);
    std::vector<double> ay; ay.reserve(opts.nummax);
    int num = 0;
    {
      std::ifstream ifs(inpath);
      double x, y;
      while (ifs >> x >> y){
        ax.push_back(x);
        ay.push_back(y);
        ++num;
      }
    }

    //Plot
    pls->col0(15);
    pls->wid(3);
    pls->env(xmin,xmax,ymin,ymax,1,0);
    pls->lab(getenv("X"),getenv("Y"),getenv("TITLE"));
    pls->line(num,ax.data(),ay.data());
    delete pls;
  }
}


int main( int argc, const char ** argv )
{
    std::vector<string> const fs = split(getenv("F"), ',');

    DataOpts const opts = filecheck(fs);

    for (std::vector<string>::const_iterator it = fs.begin(); it != fs.end(); ++it)
    {
      std::string const& f = *it;
      std::string const outpath = ("public/"+basename(f)+".png");
      plot( argc, argv, getenv("D"), f.c_str(), outpath.c_str(), opts);
      std::cout << outpath << ",";
    }

    return 0;
}
