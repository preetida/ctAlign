from os import listdir
from os.path import isfile, join
import os, sys, re
import shutil
from shutil import copyfile
import subprocess


mypath = os.getcwd()
print (mypath)
sample = mypath.split('/')[-2]
print (sample)

#mypath = "/scratch/mammoth/serial/u0944235/Bammixer2/"

onlyfiles = [f for f in listdir(mypath) if (f.endswith(".bai") or f.endswith(".tbi") or f.endswith(".vcf.gz") or f.endswith(".bam")) and isfile(join(mypath, f))]
print ("onlyfiles:",onlyfiles)


dirNames = {}

for f in onlyfiles:
   print (f)
   stub = 0
   stub = str(f.split('.')[0]) + "." + str(f.split('.')[1])
   print ("filename:",stub)
   stubDir= str(sample + '_'+ stub)
   print (stubDir)
   srcpath = mypath + '/' + f
   dstdir = mypath + '/' + stubDir 
   print ("srcpath: ", srcpath)
   print ("dstdir: ", dstdir)
   try:
       os.mkdir(dstdir)
       print ("generated dirs:", os.listdir(mypath))
   except OSError:
       print ("Creation of the directory %s failed" % dstdir)
   else:
       print ("Successfully created the directory %s " % dstdir)
   shutil.move(srcpath, dstdir)


#print("going to generate these dirs:",dirNames)
#print ("type of dirNames:", type(dirNames))

exit(0)



for dirr in dirNames:
   #print ("dirr is:", dirr)
   try:
       os.makedirs(dirr)
       print ("generated dirs:", os.listdir(mypath)) 
   except OSError:
       print ("Creation of the directory %s failed" % dirr)
   else:
       print ("Successfully created the directory %s " % dirr)

print ("dirss generated now:", os.listdir(mypath))


for file in onlyfiles:
   stubStr = str(str(stub[0]) + '.' + str(stub[1]))
   print("name of the file to match folder is:stub:",stubStr)
   for d in dirNames:
      d1=d.split('_')[3:]
      print ("dir name to match:",d1,stubStr)
      if re.match(str(d1),stubStr):
         print("stubStr is:", stubStr, "string:",d)
         print(mypath + file, mypath + dirr + '/' + file)
         #shutil.move(mypath + file, mypath + d + '/' + file)
           #process = subprocess.Popen(["bash ~/changeRG.sh"])
           #(output, error) = process.communicate()
