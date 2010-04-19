
// CTK includes
#include <ctkUtils.h>

// QT includes
#include <QStringList>

#include "ctkbstestsMyCore.h"

//-----------------------------------------------------------------------------
ctkbstestsMyCore::ctkbstestsMyCore()
{
}

//-----------------------------------------------------------------------------
ctkbstestsMyCore::~ctkbstestsMyCore()
{
}

//-----------------------------------------------------------------------------
void ctkbstestsMyCore::doSomething()
{
  QStringList inputStringList;
  inputStringList << "Testing";
  inputStringList << " is ";
  inputStringList << "awesome !";

  std::vector<std::string> outputStringVector;

  ctkUtils::qListToSTLVector(inputStringList, outputStringVector);
}
