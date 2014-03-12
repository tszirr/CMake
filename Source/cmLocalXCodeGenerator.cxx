/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2000-2009 Kitware, Inc., Insight Software Consortium

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#include "cmLocalXCodeGenerator.h"
#include "cmGlobalXCodeGenerator.h"
#include "cmSourceFile.h"
#include "cmMakefile.h"

//----------------------------------------------------------------------------
cmLocalXCodeGenerator::cmLocalXCodeGenerator()
{
  // the global generator does this, so do not
  // put these flags into the language flags
  this->EmitUniversalBinaryFlags = false;
}

//----------------------------------------------------------------------------
cmLocalXCodeGenerator::~cmLocalXCodeGenerator()
{
}

//----------------------------------------------------------------------------
std::string
cmLocalXCodeGenerator::GetTargetDirectory(cmTarget const&) const
{
  // No per-target directory for this generator (yet).
  return "";
}

//----------------------------------------------------------------------------
void cmLocalXCodeGenerator::AppendFlagEscape(std::string& flags,
                                             const std::string& rawFlag)
{
  cmGlobalXCodeGenerator* gg =
    static_cast<cmGlobalXCodeGenerator*>(this->GlobalGenerator);
  gg->AppendFlag(flags, rawFlag);
}

//----------------------------------------------------------------------------
void cmLocalXCodeGenerator::Generate()
{
  cmLocalGenerator::Generate();

  cmTargets& targets = this->Makefile->GetTargets();
  for(cmTargets::iterator iter = targets.begin();
      iter != targets.end(); ++iter)
    {
    cmTarget* t = &iter->second;
    t->HasMacOSXRpathInstallNameDir("");
    }
}

//----------------------------------------------------------------------------
void cmLocalXCodeGenerator::GenerateInstallRules()
{
  cmLocalGenerator::GenerateInstallRules();

  cmTargets& targets = this->Makefile->GetTargets();
  for(cmTargets::iterator iter = targets.begin();
      iter != targets.end(); ++iter)
    {
    cmTarget* t = &iter->second;
    t->HasMacOSXRpathInstallNameDir("");
    }
}

//----------------------------------------------------------------------------
void cmLocalXCodeGenerator::GetDirectoryForObjects(cmTarget*,
                                                   std::string&)
{
}

//----------------------------------------------------------------------------
void cmLocalXCodeGenerator::ComputeObjectDirectory(cmTarget* tgt,
                                                   std::string& dir)
{
  cmGlobalXCodeGenerator* gg =
    static_cast<cmGlobalXCodeGenerator*>(this->GlobalGenerator);
  const char* configName = gg->GetCMakeCFGIntDir();
  dir = gg->GetObjectsNormalDirectory("$(PROJECT_NAME)", configName, tgt);
  if(gg->GetXcodeVersion() >= 21)
    {
    dir += "$(CURRENT_ARCH)/";
    }
  else
    {
#ifdef __ppc__
    dir += "ppc/";
#endif
#ifdef __i386
    dir += "i386/";
#endif
    }
}

//----------------------------------------------------------------------------
void cmLocalXCodeGenerator::ComputeObjectFilenames(
                              const std::vector<cmSourceFile*> &objectSources,
                              std::vector<std::string>& objectFiles,
                              const std::string&)
{
  // Count the number of object files with each name. Warn about duplicate
  // names since Xcode names them uniquely automatically with a numeric suffix
  // to avoid exact duplicate file names. Note that Mac file names are not
  // typically case sensitive, hence the LowerCase.
  std::map<std::string, int> counts;
  for(std::vector<cmSourceFile*>::const_iterator
      si = objectSources.begin();
      si != objectSources.end(); ++si)
    {
    cmSourceFile* sf = *si;
    std::string objectName =
      cmSystemTools::GetFilenameWithoutLastExtension(sf->GetFullPath());
    objectName += ".o";

    std::string objectNameLower = cmSystemTools::LowerCase(objectName);
    counts[objectNameLower] += 1;
    if (2 == counts[objectNameLower])
      {
      // TODO: emit warning about duplicate name?
      }
    objectFiles.push_back(objectName);
    }
}
