PImage img=loadImage("font.png");
int W=165;

String bits="";
int[] offsets=new int[96];
int[] widths=new int[96];

int lastID=0;

for(int x=0; x<W; x++) {
  int val=0;
  for(int y=0,b=128; y<7; y++,b>>=1) {
    if ((img.pixels[x+y*img.width]&0xff)==0) {
      val|=b;
    }
  }
  bits+=val+",";
  int id=(int)red(img.pixels[7*img.width+x]);
  if (id<255) {
      println(id);
    id-=32;
    widths[lastID]=x-offsets[lastID];
    offsets[id]=x;
    lastID=id;
  } 
}
println("const byte font["+W+"]={ "+bits+" };");
print("const int offsets[96]={ ");
for(int i=0; i<offsets.length; i++) {
  print(offsets[i]+",");
}
println(" };");
print("const int widths[96]={ ");
for(int i=0; i<widths.length; i++) {
  print(widths[i]+",");
}
println(" };");
