module Annotation
  ( module'
  ) where

import "rio" RIO hiding (log, span)

import qualified "base" Data.Bitraversable
import qualified "purescript" Language.PureScript.CST
import qualified "this" Log
import qualified "this" SourceRange
import qualified "this" Span

adoBlock ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.AdoBlock a ->
  IO (Language.PureScript.CST.AdoBlock Span.Span)
adoBlock log adoBlock' = case adoBlock' of
  Language.PureScript.CST.AdoBlock ado doStatements' in' expr'' -> do
    let span = Span.adoBlock adoBlock'
    debug log "AdoBlock" adoBlock' span
    doStatements <- traverse (doStatement log) doStatements'
    expr' <- expr log expr''
    pure (Language.PureScript.CST.AdoBlock ado doStatements in' expr')

binder ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Binder a ->
  IO (Language.PureScript.CST.Binder Span.Span)
binder log binder''' = case binder''' of
  Language.PureScript.CST.BinderArray _ delimited'' -> do
    let span = Span.binder binder'''
    debug log "BinderArray" binder''' span
    delimited' <- delimited log (binder log) delimited''
    pure (Language.PureScript.CST.BinderArray span delimited')
  Language.PureScript.CST.BinderBoolean _ boolean x -> do
    let span = Span.binder binder'''
    debug log "BinderBoolean" binder''' span
    pure (Language.PureScript.CST.BinderBoolean span boolean x)
  Language.PureScript.CST.BinderChar _ char x -> do
    let span = Span.binder binder'''
    debug log "BinderChar" binder''' span
    pure (Language.PureScript.CST.BinderChar span char x)
  Language.PureScript.CST.BinderConstructor _ name' binders' -> do
    let span = Span.binder binder'''
    debug log "BinderConstructor" binder''' span
    binders <- traverse (binder log) binders'
    pure (Language.PureScript.CST.BinderConstructor span name' binders)
  Language.PureScript.CST.BinderNamed _ name' at binder'' -> do
    let span = Span.binder binder'''
    debug log "BinderNamed" binder''' span
    binder' <- binder log binder''
    pure (Language.PureScript.CST.BinderNamed span name' at binder')
  Language.PureScript.CST.BinderNumber _ negative number x -> do
    let span = Span.binder binder'''
    debug log "BinderNumber" binder''' span
    pure (Language.PureScript.CST.BinderNumber span negative number x)
  Language.PureScript.CST.BinderOp _ binder1' op binder2' -> do
    let span = Span.binder binder'''
    debug log "BinderOp" binder''' span
    binder1 <- binder log binder1'
    binder2 <- binder log binder2'
    pure (Language.PureScript.CST.BinderOp span binder1 op binder2)
  Language.PureScript.CST.BinderParens _ wrapped'' -> do
    let span = Span.binder binder'''
    debug log "BinderParens" binder''' span
    wrapped' <- wrapped log (binder log) wrapped''
    pure (Language.PureScript.CST.BinderParens span wrapped')
  Language.PureScript.CST.BinderRecord _ delimited'' -> do
    let span = Span.binder binder'''
    debug log "BinderRecord" binder''' span
    delimited' <-
      delimited
        log
        (recordLabeled log SourceRange.binder $ binder log)
        delimited''
    pure (Language.PureScript.CST.BinderRecord span delimited')
  Language.PureScript.CST.BinderString _ string x -> do
    let span = Span.binder binder'''
    debug log "BinderString" binder''' span
    pure (Language.PureScript.CST.BinderString span string x)
  Language.PureScript.CST.BinderTyped _ binder'' typed type''' -> do
    let span = Span.binder binder'''
    debug log "BinderTyped" binder''' span
    binder' <- binder log binder''
    type'' <- type' log type'''
    pure (Language.PureScript.CST.BinderTyped span binder' typed type'')
  Language.PureScript.CST.BinderVar _ var -> do
    let span = Span.binder binder'''
    debug log "BinderVar" binder''' span
    pure (Language.PureScript.CST.BinderVar span var)
  Language.PureScript.CST.BinderWildcard _ wildcard -> do
    let span = Span.binder binder'''
    debug log "BinderWildcard" binder''' span
    pure (Language.PureScript.CST.BinderWildcard span wildcard)

caseOf ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.CaseOf a ->
  IO (Language.PureScript.CST.CaseOf Span.Span)
caseOf log caseOf' = case caseOf' of
  Language.PureScript.CST.CaseOf case' head' of' branches' -> do
    let span = Span.caseOf caseOf'
    debug log "CaseOf" caseOf' span
    head <- traverse (expr log) head'
    branches <-
      traverse
        (Data.Bitraversable.bitraverse (traverse $ binder log) $ guarded log)
        branches'
    pure (Language.PureScript.CST.CaseOf case' head of' branches)

classHead ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.ClassHead a ->
  IO (Language.PureScript.CST.ClassHead Span.Span)
classHead log classHead' = case classHead' of
  Language.PureScript.CST.ClassHead class' super' name' typeVarBindings'' fundeps -> do
    let span = Span.SingleLine
    debug log "ClassHead" classHead' span
    super <- (traverse . ltraverse . traverse) (constraint log) super'
    typeVarBindings' <- traverse (typeVarBinding log) typeVarBindings''
    pure
      ( Language.PureScript.CST.ClassHead
        class'
        super
        name'
        typeVarBindings'
        fundeps
      )

constraint ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Constraint a ->
  IO (Language.PureScript.CST.Constraint Span.Span)
constraint log constraint' = case constraint' of
  Language.PureScript.CST.Constraint _ name' types' -> do
    let span = Span.constraint constraint'
    debug log "Constraint" constraint' span
    types <- traverse (type' log) types'
    pure (Language.PureScript.CST.Constraint span name' types)
  Language.PureScript.CST.ConstraintParens _ wrapped'' -> do
    let span = Span.constraint constraint'
    debug log "ConstraintParens" constraint' span
    wrapped' <- wrapped log (constraint log) wrapped''
    pure (Language.PureScript.CST.ConstraintParens span wrapped')

dataCtor ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.DataCtor a ->
  IO (Language.PureScript.CST.DataCtor Span.Span)
dataCtor log dataCtor' = case dataCtor' of
  Language.PureScript.CST.DataCtor _ name' types' -> do
    let span = Span.dataCtor dataCtor'
    debug log "DataCtor" dataCtor' span
    types <- traverse (type' log) types'
    pure (Language.PureScript.CST.DataCtor span name' types)

dataHead ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.DataHead a ->
  IO (Language.PureScript.CST.DataHead Span.Span)
dataHead log dataHead' = case dataHead' of
  Language.PureScript.CST.DataHead sourceToken' name' typeVarBindings'' -> do
    let span = Span.SingleLine
    debug log "DataHead" dataHead' span
    typeVarBindings' <- traverse (typeVarBinding log) typeVarBindings''
    pure (Language.PureScript.CST.DataHead sourceToken' name' typeVarBindings')

dataMembers ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.DataMembers a ->
  IO (Language.PureScript.CST.DataMembers Span.Span)
dataMembers log dataMembers' = case dataMembers' of
  Language.PureScript.CST.DataAll _ sourceToken' -> do
    let span = Span.SingleLine
    debug log "DataAll" dataMembers' span
    pure (Language.PureScript.CST.DataAll span sourceToken')
  Language.PureScript.CST.DataEnumerated _ delimited' -> do
    let span = Span.dataMembers dataMembers'
    debug log "DataEnumerated" dataMembers' span
    pure (Language.PureScript.CST.DataEnumerated span delimited')

debug :: (Show a) => Log.Handle -> Utf8Builder -> a -> Span.Span -> IO ()
debug log x y z =
  Log.debug
    log
    ( "Annotating `"
      <> x
      <> "`: "
      <> displayShow y
      <> " as `"
      <> displayShow z
      <> "`"
    )

declaration ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Declaration a ->
  IO (Language.PureScript.CST.Declaration Span.Span)
declaration log declaration' = case declaration' of
  Language.PureScript.CST.DeclData _ dataHead'' dataCtors' -> do
    let span = Span.MultipleLines
    debug log "DeclData" declaration' span
    dataHead' <- dataHead log dataHead''
    dataCtors <- (traverse . traverse . traverse) (dataCtor log) dataCtors'
    pure (Language.PureScript.CST.DeclData span dataHead' dataCtors)
  Language.PureScript.CST.DeclClass _ classHead'' body' -> do
    let span = Span.declaration declaration'
    debug log "DeclClass" declaration' span
    classHead' <- classHead log classHead''
    body <- (traverse . traverse . traverse . traverse) (type' log) body'
    pure (Language.PureScript.CST.DeclClass span classHead' body)
  Language.PureScript.CST.DeclDerive _ derive newtype' instanceHead'' -> do
    let span = Span.declaration declaration'
    debug log "DeclDerive" declaration' span
    instanceHead' <- instanceHead log instanceHead''
    pure (Language.PureScript.CST.DeclDerive span derive newtype' instanceHead')
  Language.PureScript.CST.DeclFixity _ fixityFields -> do
    let span = Span.SingleLine
    debug log "DeclFixity" declaration' span
    pure (Language.PureScript.CST.DeclFixity span fixityFields)
  Language.PureScript.CST.DeclForeign _ foreign'' import'' foreign'''' -> do
    let span = Span.declaration declaration'
    debug log "DeclForeign" declaration' span
    foreign''' <- foreign' log foreign''''
    pure (Language.PureScript.CST.DeclForeign span foreign'' import'' foreign''')
  Language.PureScript.CST.DeclInstanceChain _ separated'' -> do
    let span = Span.declaration declaration'
    debug log "DeclInstanceChain" declaration' span
    separated' <- traverse (instance' log) separated''
    pure (Language.PureScript.CST.DeclInstanceChain span separated')
  Language.PureScript.CST.DeclNewtype _ dataHead'' equals name' type''' -> do
    let span = Span.MultipleLines
    debug log "DeclNewtype" declaration' span
    dataHead' <- dataHead log dataHead''
    type'' <- type' log type'''
    pure (Language.PureScript.CST.DeclNewtype span dataHead' equals name' type'')
  Language.PureScript.CST.DeclSignature _ labeled'' -> do
    let span = Span.labeled SourceRange.name SourceRange.type' labeled''
    debug log "DeclSignature" declaration' span
    labeled' <- labeledNameType log labeled''
    pure (Language.PureScript.CST.DeclSignature span labeled')
  Language.PureScript.CST.DeclType _ dataHead'' equals type''' -> do
    let span = Span.MultipleLines
    debug log "DeclType" declaration' span
    dataHead' <- dataHead log dataHead''
    type'' <- type' log type'''
    pure (Language.PureScript.CST.DeclType span dataHead' equals type'')
  Language.PureScript.CST.DeclValue _ valueBindingFields'' -> do
    let span = Span.valueBindingFields valueBindingFields''
    debug log "DeclValue" declaration' span
    valueBindingFields' <- valueBindingFields log valueBindingFields''
    pure (Language.PureScript.CST.DeclValue span valueBindingFields')

delimited ::
  (Show a) =>
  Log.Handle ->
  (a -> IO b) ->
  Language.PureScript.CST.Delimited a ->
  IO (Language.PureScript.CST.Delimited b)
delimited log f =
  wrapped log ((traverse . traverse) f)

delimitedNonEmpty ::
  (Show a) =>
  Log.Handle ->
  (a -> IO b) ->
  Language.PureScript.CST.DelimitedNonEmpty a ->
  IO (Language.PureScript.CST.DelimitedNonEmpty b)
delimitedNonEmpty log f =
  wrapped log (traverse f)

doBlock ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.DoBlock a ->
  IO (Language.PureScript.CST.DoBlock Span.Span)
doBlock log doBlock' = case doBlock' of
  Language.PureScript.CST.DoBlock do' doStatements' -> do
    let span = Span.doBlock doBlock'
    debug log "DoBlock" doBlock' span
    doStatements <- traverse (doStatement log) doStatements'
    pure (Language.PureScript.CST.DoBlock do' doStatements)

doStatement ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.DoStatement a ->
  IO (Language.PureScript.CST.DoStatement Span.Span)
doStatement log doStatement' = case doStatement' of
  Language.PureScript.CST.DoBind binder'' arrow expr'' -> do
    let span = Span.doStatement doStatement'
    debug log "DoBind" doStatement' span
    binder' <- binder log binder''
    expr' <- expr log expr''
    pure (Language.PureScript.CST.DoBind binder' arrow expr')
  Language.PureScript.CST.DoDiscard expr'' -> do
    let span = Span.doStatement doStatement'
    debug log "DoDiscard" doStatement' span
    expr' <- expr log expr''
    pure (Language.PureScript.CST.DoDiscard expr')
  Language.PureScript.CST.DoLet let' letBindings'' -> do
    let span = Span.doStatement doStatement'
    debug log "DoLet" doStatement' span
    letBindings' <- traverse (letBinding log) letBindings''
    pure (Language.PureScript.CST.DoLet let' letBindings')

export ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Export a ->
  IO (Language.PureScript.CST.Export Span.Span)
export log export' = case export' of
  Language.PureScript.CST.ExportClass _ class' name' -> do
    debug log "ExportClass" name' span
    pure (Language.PureScript.CST.ExportClass span class' name')
  Language.PureScript.CST.ExportKind _ kind' name' -> do
    debug log "ExportKind" name' span
    pure (Language.PureScript.CST.ExportKind span kind' name')
  Language.PureScript.CST.ExportModule _ module'' name' -> do
    debug log "ExportModule" name' span
    pure (Language.PureScript.CST.ExportModule span module'' name')
  Language.PureScript.CST.ExportOp _ name' -> do
    debug log "ExportOp" name' span
    pure (Language.PureScript.CST.ExportOp span name')
  Language.PureScript.CST.ExportType _ name' dataMembers'' -> do
    debug log "ExportType" name' span
    dataMembers' <- traverse (dataMembers log) dataMembers''
    pure (Language.PureScript.CST.ExportType span name' dataMembers')
  Language.PureScript.CST.ExportTypeOp _ type'' name' -> do
    debug log "ExportTypeOp" name' span
    pure (Language.PureScript.CST.ExportTypeOp span type'' name')
  Language.PureScript.CST.ExportValue _ name' -> do
    debug log "ExportValue" name' span
    pure (Language.PureScript.CST.ExportValue span name')
  where
  span :: Span.Span
  span = Span.export export'

expr ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Expr a ->
  IO (Language.PureScript.CST.Expr Span.Span)
expr log expr''' = case expr''' of
  Language.PureScript.CST.ExprAdo _ adoBlock'' -> do
    let span = Span.expr expr'''
    debug log "ExprAdo" expr''' span
    adoBlock' <- adoBlock log adoBlock''
    pure (Language.PureScript.CST.ExprAdo span adoBlock')
  Language.PureScript.CST.ExprApp _ expr1' expr2' -> do
    let span = Span.expr expr'''
    debug log "ExprApp" expr''' span
    expr1 <- expr log expr1'
    expr2 <- expr log expr2'
    pure (Language.PureScript.CST.ExprApp span expr1 expr2)
  Language.PureScript.CST.ExprArray _ delimited'' -> do
    let span = Span.expr expr'''
    debug log "ExprArray" expr''' span
    delimited' <- delimited log (expr log) delimited''
    pure (Language.PureScript.CST.ExprArray span delimited')
  Language.PureScript.CST.ExprBoolean _ boolean x -> do
    let span = Span.expr expr'''
    debug log "ExprBoolean" expr''' span
    pure (Language.PureScript.CST.ExprBoolean span boolean x)
  Language.PureScript.CST.ExprCase _ caseOf'' -> do
    let span = Span.expr expr'''
    debug log "ExprCase" expr''' span
    caseOf' <- caseOf log caseOf''
    pure (Language.PureScript.CST.ExprCase span caseOf')
  Language.PureScript.CST.ExprChar _ char x -> do
    let span = Span.expr expr'''
    debug log "ExprChar" expr''' span
    pure (Language.PureScript.CST.ExprChar span char x)
  Language.PureScript.CST.ExprConstructor _ name' -> do
    let span = Span.expr expr'''
    debug log "ExprConstructor" expr''' span
    pure (Language.PureScript.CST.ExprConstructor span name')
  Language.PureScript.CST.ExprDo _ doBlock'' -> do
    let span = Span.expr expr'''
    debug log "ExprDo" expr''' span
    doBlock' <- doBlock log doBlock''
    pure (Language.PureScript.CST.ExprDo span doBlock')
  Language.PureScript.CST.ExprHole _ hole -> do
    let span = Span.expr expr'''
    debug log "ExprHole" expr''' span
    pure (Language.PureScript.CST.ExprHole span hole)
  Language.PureScript.CST.ExprIdent _ name' -> do
    let span = Span.expr expr'''
    debug log "ExprIdent" expr''' span
    pure (Language.PureScript.CST.ExprIdent span name')
  Language.PureScript.CST.ExprIf _ ifThenElse'' -> do
    let span = Span.expr expr'''
    debug log "ExprIf" expr''' span
    ifThenElse' <- ifThenElse log ifThenElse''
    pure (Language.PureScript.CST.ExprIf span ifThenElse')
  Language.PureScript.CST.ExprInfix _ expr1' wrapped'' expr2' -> do
    let span = Span.expr expr'''
    debug log "ExprInfix" expr''' span
    expr1 <- expr log expr1'
    wrapped' <- wrapped log (expr log) wrapped''
    expr2 <- expr log expr2'
    pure (Language.PureScript.CST.ExprInfix span expr1 wrapped' expr2)
  Language.PureScript.CST.ExprLambda _ lambda'' -> do
    let span = Span.expr expr'''
    debug log "ExprLambda" expr''' span
    lambda' <- lambda log lambda''
    pure (Language.PureScript.CST.ExprLambda span lambda')
  Language.PureScript.CST.ExprLet _ letIn'' -> do
    let span = Span.expr expr'''
    debug log "ExprLet" expr''' span
    letIn' <- letIn log letIn''
    pure (Language.PureScript.CST.ExprLet span letIn')
  Language.PureScript.CST.ExprNegate _ negative expr'' -> do
    let span = Span.expr expr'''
    debug log "ExprNegate" expr''' span
    expr' <- expr log expr''
    pure (Language.PureScript.CST.ExprNegate span negative expr')
  Language.PureScript.CST.ExprNumber _ number x -> do
    let span = Span.expr expr'''
    debug log "ExprNumber" expr''' span
    pure (Language.PureScript.CST.ExprNumber span number x)
  Language.PureScript.CST.ExprOp _ expr1' op expr2' -> do
    let span = Span.expr expr'''
    debug log "ExprOp" expr''' span
    expr1 <- expr log expr1'
    expr2 <- expr log expr2'
    pure (Language.PureScript.CST.ExprOp span expr1 op expr2)
  Language.PureScript.CST.ExprOpName _ name' -> do
    let span = Span.expr expr'''
    debug log "ExprOpName" expr''' span
    pure (Language.PureScript.CST.ExprOpName span name')
  Language.PureScript.CST.ExprParens _ wrapped'' -> do
    let span = Span.expr expr'''
    debug log "ExprParens" expr''' span
    wrapped' <- wrapped log (expr log) wrapped''
    pure (Language.PureScript.CST.ExprParens span wrapped')
  Language.PureScript.CST.ExprRecord _ delimited'' -> do
    let span = Span.expr expr'''
    debug log "ExprRecord" expr''' span
    delimited' <-
      delimited
        log
        (recordLabeled log SourceRange.expr $ expr log)
        delimited''
    pure (Language.PureScript.CST.ExprRecord span delimited')
  Language.PureScript.CST.ExprRecordAccessor _ recordAccessor'' -> do
    let span = Span.expr expr'''
    debug log "ExprRecordAccessor" expr''' span
    recordAccessor' <- recordAccessor log recordAccessor''
    pure (Language.PureScript.CST.ExprRecordAccessor span recordAccessor')
  Language.PureScript.CST.ExprRecordUpdate _ expr'' delimitedNonEmpty'' -> do
    let span = Span.expr expr'''
    debug log "ExprRecordUpdate" expr''' span
    expr' <- expr log expr''
    delimitedNonEmpty' <-
      delimitedNonEmpty log (recordUpdate log) delimitedNonEmpty''
    pure (Language.PureScript.CST.ExprRecordUpdate span expr' delimitedNonEmpty')
  Language.PureScript.CST.ExprSection _ section -> do
    let span = Span.expr expr'''
    debug log "ExprSection" expr''' span
    pure (Language.PureScript.CST.ExprSection span section)
  Language.PureScript.CST.ExprString _ string x -> do
    let span = Span.expr expr'''
    debug log "ExprString" expr''' span
    pure (Language.PureScript.CST.ExprString span string x)
  Language.PureScript.CST.ExprTyped _ expr'' op type''' -> do
    let span = Span.expr expr'''
    debug log "ExprTyped" expr''' span
    expr' <- expr log expr''
    type'' <- type' log type'''
    pure (Language.PureScript.CST.ExprTyped span expr' op type'')

foreign' ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Foreign a ->
  IO (Language.PureScript.CST.Foreign Span.Span)
foreign' log foreign'' = case foreign'' of
  Language.PureScript.CST.ForeignData data' labeled'' -> do
    let span = Span.foreign' foreign''
    debug log "ForeignData" foreign'' span
    labeled' <- traverse (kind log) labeled''
    pure (Language.PureScript.CST.ForeignData data' labeled')
  Language.PureScript.CST.ForeignKind kind' name' -> do
    let span = Span.foreign' foreign''
    debug log "ForeignKind" foreign'' span
    pure (Language.PureScript.CST.ForeignKind kind' name')
  Language.PureScript.CST.ForeignValue labeled'' -> do
    let span = Span.foreign' foreign''
    debug log "ForeignValue" foreign'' span
    labeled' <- traverse (type' log) labeled''
    pure (Language.PureScript.CST.ForeignValue labeled')

guarded ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Guarded a ->
  IO (Language.PureScript.CST.Guarded Span.Span)
guarded log guarded' = case guarded' of
  Language.PureScript.CST.Guarded guardedExprs' -> do
    let span = Span.guarded guarded'
    debug log "Guarded" guarded' span
    guardedExprs <- traverse (guardedExpr log) guardedExprs'
    pure (Language.PureScript.CST.Guarded guardedExprs)
  Language.PureScript.CST.Unconditional sourceToken' where''' -> do
    let span = Span.guarded guarded'
    debug log "Unconditional" guarded' span
    where'' <- where' log where'''
    pure (Language.PureScript.CST.Unconditional sourceToken' where'')

guardedExpr ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.GuardedExpr a ->
  IO (Language.PureScript.CST.GuardedExpr Span.Span)
guardedExpr log guardedExpr' = case guardedExpr' of
  Language.PureScript.CST.GuardedExpr bar patternGuards' comma where''' -> do
    let span = Span.guardedExpr guardedExpr'
    debug log "GuardedExpr" guardedExpr' span
    patternGuards <- traverse (patternGuard log) patternGuards'
    where'' <- where' log where'''
    pure (Language.PureScript.CST.GuardedExpr bar patternGuards comma where'')

ifThenElse ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.IfThenElse a ->
  IO (Language.PureScript.CST.IfThenElse Span.Span)
ifThenElse log ifThenElse' = case ifThenElse' of
  Language.PureScript.CST.IfThenElse if' cond' then' true' else' false' -> do
    let span = Span.ifThenElse ifThenElse'
    debug log "IfThenElse" ifThenElse' span
    cond <- expr log cond'
    true <- expr log true'
    false <- expr log false'
    pure (Language.PureScript.CST.IfThenElse if' cond then' true else' false)

import' ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Import a ->
  IO (Language.PureScript.CST.Import Span.Span)
import' log import'' = case import'' of
  Language.PureScript.CST.ImportClass _ class' name' -> do
    debug log "ImportClass" name' span
    pure (Language.PureScript.CST.ImportClass span class' name')
  Language.PureScript.CST.ImportKind _ kind' name' -> do
    debug log "ImportKind" name' span
    pure (Language.PureScript.CST.ImportKind span kind' name')
  Language.PureScript.CST.ImportOp _ name' -> do
    debug log "ImportOp" name' span
    pure (Language.PureScript.CST.ImportOp span name')
  Language.PureScript.CST.ImportType _ name' dataMembers'' -> do
    debug log "ImportType" name' span
    dataMembers' <- traverse (dataMembers log) dataMembers''
    pure (Language.PureScript.CST.ImportType span name' dataMembers')
  Language.PureScript.CST.ImportTypeOp _ type'' name' -> do
    debug log "ImportTypeOp" name' span
    pure (Language.PureScript.CST.ImportTypeOp span type'' name')
  Language.PureScript.CST.ImportValue _ name' -> do
    debug log "ImportValue" name' span
    pure (Language.PureScript.CST.ImportValue span name')
  where
  span :: Span.Span
  span = Span.import' import''

importDecl ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.ImportDecl a ->
  IO (Language.PureScript.CST.ImportDecl Span.Span)
importDecl log importDecl' = case importDecl' of
  Language.PureScript.CST.ImportDecl _ import'' name' imports' rename -> do
    let span = Span.importDecl importDecl'
    debug log "ImportDecl" importDecl' span
    imports <- (traverse . traverse . traverse . traverse) (import' log) imports'
    pure (Language.PureScript.CST.ImportDecl span import'' name' imports rename)

instance' ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Instance a ->
  IO (Language.PureScript.CST.Instance Span.Span)
instance' log instance'' = case instance'' of
  Language.PureScript.CST.Instance instanceHead'' body' -> do
    let span = Span.instance' instance''
    debug log "Instance" instance'' span
    instanceHead' <- instanceHead log instanceHead''
    body <- (traverse . traverse . traverse) (instanceBinding log) body'
    pure (Language.PureScript.CST.Instance instanceHead' body)

instanceBinding ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.InstanceBinding a ->
  IO (Language.PureScript.CST.InstanceBinding Span.Span)
instanceBinding log instanceBinding' = case instanceBinding' of
  Language.PureScript.CST.InstanceBindingName _ valueBindingFields'' -> do
    let span = Span.instanceBinding instanceBinding'
    debug log "InstanceBindingName" instanceBinding' span
    valueBindingFields' <- valueBindingFields log valueBindingFields''
    pure ( Language.PureScript.CST.InstanceBindingName span valueBindingFields')
  Language.PureScript.CST.InstanceBindingSignature _ labeled'' -> do
    let span = Span.instanceBinding instanceBinding'
    debug log "InstanceBindingSignature" instanceBinding' span
    labeled' <- labeledNameType log labeled''
    pure ( Language.PureScript.CST.InstanceBindingSignature span labeled')

instanceHead ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.InstanceHead a ->
  IO (Language.PureScript.CST.InstanceHead Span.Span)
instanceHead log instanceHead' = case instanceHead' of
  Language.PureScript.CST.InstanceHead instance'' name' colons constraints' class' types' -> do
    let span = Span.instanceHead instanceHead'
    debug log "InstanceHead" instanceHead' span
    constraints <-
      (traverse . ltraverse . traverse) (constraint log) constraints'
    types <- traverse (type' log) types'
    pure
      ( Language.PureScript.CST.InstanceHead
        instance''
        name'
        colons
        constraints
        class'
        types
      )

kind ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Kind a ->
  IO (Language.PureScript.CST.Kind Span.Span)
kind log kind''' = case kind''' of
  Language.PureScript.CST.KindArr _ kind1' arrow kind2' -> do
    let span = Span.kind kind'''
    debug log "KindArr" kind''' span
    kind1 <- kind log kind1'
    kind2 <- kind log kind2'
    pure (Language.PureScript.CST.KindArr span kind1 arrow kind2)
  Language.PureScript.CST.KindName _ name' -> do
    let span = Span.kind kind'''
    debug log "KindName" kind''' span
    pure (Language.PureScript.CST.KindName span name')
  Language.PureScript.CST.KindParens _ wrapped'' -> do
    let span = Span.kind kind'''
    debug log "KindParens" kind''' span
    wrapped' <- wrapped log (kind log) wrapped''
    pure (Language.PureScript.CST.KindParens span wrapped')
  Language.PureScript.CST.KindRow _ sourceToken kind'' -> do
    let span = Span.kind kind'''
    debug log "KindRow" kind''' span
    kind' <- kind log kind''
    pure (Language.PureScript.CST.KindRow span sourceToken kind')

labeled ::
  (Show a, Show b) =>
  Log.Handle ->
  (a -> Language.PureScript.CST.SourceRange) ->
  (b -> Language.PureScript.CST.SourceRange) ->
  (b -> IO c) ->
  Language.PureScript.CST.Labeled a b ->
  IO (Language.PureScript.CST.Labeled a c)
labeled log f g h labeled' = case labeled' of
  Language.PureScript.CST.Labeled label' separator value' -> do
    let span = Span.labeled f g labeled'
    debug log "Labeled" labeled' span
    value <- h value'
    pure (Language.PureScript.CST.Labeled label' separator value)

labeledNameKind ::
  (Show a, Show b) =>
  Log.Handle ->
  Language.PureScript.CST.Labeled
    (Language.PureScript.CST.Name a)
    (Language.PureScript.CST.Kind b) ->
  IO
    ( Language.PureScript.CST.Labeled
      (Language.PureScript.CST.Name a)
      (Language.PureScript.CST.Kind Span.Span)
    )
labeledNameKind log = labeled log SourceRange.name SourceRange.kind (kind log)

labeledNameType ::
  (Show a, Show b) =>
  Log.Handle ->
  Language.PureScript.CST.Labeled
    (Language.PureScript.CST.Name a)
    (Language.PureScript.CST.Type b) ->
  IO
    ( Language.PureScript.CST.Labeled
      (Language.PureScript.CST.Name a)
      (Language.PureScript.CST.Type Span.Span)
    )
labeledNameType log = labeled log SourceRange.name SourceRange.type' (type' log)

lambda ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Lambda a ->
  IO (Language.PureScript.CST.Lambda Span.Span)
lambda log lambda' = case lambda' of
  Language.PureScript.CST.Lambda reverseSolidus binders' arrow expr'' -> do
    let span = Span.lambda lambda'
    debug log "Lambda" lambda' span
    binders <- traverse (binder log) binders'
    expr' <- expr log expr''
    pure (Language.PureScript.CST.Lambda reverseSolidus binders arrow expr')

letBinding ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.LetBinding a ->
  IO (Language.PureScript.CST.LetBinding Span.Span)
letBinding log letBinding' = case letBinding' of
  Language.PureScript.CST.LetBindingName _ valueBindingFields'' -> do
    let span = Span.letBinding letBinding'
    debug log "LetBindingName" letBinding' span
    valueBindingFields' <- valueBindingFields log valueBindingFields''
    pure (Language.PureScript.CST.LetBindingName span valueBindingFields')
  Language.PureScript.CST.LetBindingPattern _ binder'' equals where''' -> do
    let span = Span.letBinding letBinding'
    debug log "LetBindingPattern" letBinding' span
    binder' <- binder log binder''
    where'' <- where' log where'''
    pure (Language.PureScript.CST.LetBindingPattern span binder' equals where'')
  Language.PureScript.CST.LetBindingSignature _ labeled'' -> do
    let span = Span.letBinding letBinding'
    debug log "LetBindingSignature" letBinding' span
    labeled' <- labeledNameType log labeled''
    pure (Language.PureScript.CST.LetBindingSignature span labeled')

letIn ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.LetIn a ->
  IO (Language.PureScript.CST.LetIn Span.Span)
letIn log letIn' = case letIn' of
  Language.PureScript.CST.LetIn let' bindings' in' expr'' -> do
    let span = Span.letIn letIn'
    debug log "LetIn" letIn' span
    expr' <- expr log expr''
    bindings <- traverse (letBinding log) bindings'
    pure (Language.PureScript.CST.LetIn let' bindings in' expr')

ltraverse ::
  (Data.Bitraversable.Bitraversable t, Applicative f) =>
  (a -> f c) ->
  t a d ->
  f (t c d)
ltraverse f = Data.Bitraversable.bitraverse f pure

module' ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Module a ->
  IO (Language.PureScript.CST.Module Span.Span)
module' log module''' = case module''' of
  Language.PureScript.CST.Module _ module'' name exports' where'' imports' declarations' trailing -> do
    let span = Span.betweenSourceTokens module'' where''
    debug log "Module" module''' span
    exports <- (traverse . traverse . traverse) (export log) exports'
    imports <- traverse (importDecl log) imports'
    declarations <- traverse (declaration log) declarations'
    pure
      ( Language.PureScript.CST.Module
        span
        module''
        name
        exports
        where''
        imports
        declarations
        trailing
      )

patternGuard ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.PatternGuard a ->
  IO (Language.PureScript.CST.PatternGuard Span.Span)
patternGuard log patternGuard' = case patternGuard' of
  Language.PureScript.CST.PatternGuard binder'' expr'' -> do
    let span = Span.patternGuard patternGuard'
    debug log "PatternGuard" patternGuard' span
    binder' <- (traverse . ltraverse) (binder log) binder''
    expr' <- expr log expr''
    pure (Language.PureScript.CST.PatternGuard binder' expr')

recordAccessor ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.RecordAccessor a ->
  IO (Language.PureScript.CST.RecordAccessor Span.Span)
recordAccessor log recordAccessor' = case recordAccessor' of
  Language.PureScript.CST.RecordAccessor expr'' dot path -> do
    let span = Span.recordAccessor recordAccessor'
    debug log "RecordAccessor" recordAccessor' span
    expr' <- expr log expr''
    pure (Language.PureScript.CST.RecordAccessor expr' dot path)

recordLabeled ::
  (Show a) =>
  Log.Handle ->
  (a -> Language.PureScript.CST.SourceRange) ->
  (a -> IO b) ->
  Language.PureScript.CST.RecordLabeled a ->
  IO (Language.PureScript.CST.RecordLabeled b)
recordLabeled log f g recordLabeled' = case recordLabeled' of
  Language.PureScript.CST.RecordPun name' -> do
    let span = Span.recordLabeled f recordLabeled'
    debug log "RecordPun" recordLabeled' span
    pure (Language.PureScript.CST.RecordPun name')
  Language.PureScript.CST.RecordField label' colon a -> do
    let span = Span.recordLabeled f recordLabeled'
    debug log "RecordField" recordLabeled' span
    b <- g a
    pure (Language.PureScript.CST.RecordField label' colon b)

recordUpdate ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.RecordUpdate a ->
  IO (Language.PureScript.CST.RecordUpdate Span.Span)
recordUpdate log recordUpdate' = case recordUpdate' of
  Language.PureScript.CST.RecordUpdateBranch label' delimitedNonEmpty'' -> do
    let span = Span.recordUpdate recordUpdate'
    debug log "RecordPun" recordUpdate' span
    delimitedNonEmpty' <-
      delimitedNonEmpty log (recordUpdate log) delimitedNonEmpty''
    pure (Language.PureScript.CST.RecordUpdateBranch label' delimitedNonEmpty')
  Language.PureScript.CST.RecordUpdateLeaf label' equals expr'' -> do
    let span = Span.recordUpdate recordUpdate'
    debug log "RecordField" recordUpdate' span
    expr' <- expr log expr''
    pure (Language.PureScript.CST.RecordUpdateLeaf label' equals expr')

row ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Row a ->
  IO (Language.PureScript.CST.Row Span.Span)
row log row' = case row' of
  Language.PureScript.CST.Row labels' tail' -> do
    let span = Span.row row'
    debug log "Row" row' span
    labels <- (traverse . traverse . traverse) (type' log) labels'
    tail <- (traverse . traverse) (type' log) tail'
    pure (Language.PureScript.CST.Row labels tail)

type' ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Type a ->
  IO (Language.PureScript.CST.Type Span.Span)
type' log type'''' = case type'''' of
  Language.PureScript.CST.TypeApp _ type1' type2' -> do
    let span = Span.type' type''''
    debug log "TypeApp" type'''' span
    type1 <- type' log type1'
    type2 <- type' log type2'
    pure (Language.PureScript.CST.TypeApp span type1 type2)
  Language.PureScript.CST.TypeArr _ type1' arrow type2' -> do
    let span = Span.type' type''''
    debug log "TypeArr" type'''' span
    type1 <- type' log type1'
    type2 <- type' log type2'
    pure (Language.PureScript.CST.TypeArr span type1 arrow type2)
  Language.PureScript.CST.TypeArrName _ arrow -> do
    let span = Span.type' type''''
    debug log "TypeArrName" type'''' span
    pure (Language.PureScript.CST.TypeArrName span arrow)
  Language.PureScript.CST.TypeConstrained _ constraint'' arrow type''' -> do
    let span = Span.type' type''''
    debug log "TypeConstrained" type'''' span
    constraint' <- constraint log constraint''
    type'' <- type' log type'''
    pure (Language.PureScript.CST.TypeConstrained span constraint' arrow type'')
  Language.PureScript.CST.TypeConstructor _ name' -> do
    let span = Span.type' type''''
    debug log "TypeConstructor" type'''' span
    pure (Language.PureScript.CST.TypeConstructor span name')
  Language.PureScript.CST.TypeForall _ forall' typeVarBindings' dot type''' -> do
    let span = Span.type' type''''
    debug log "TypeForall" type'''' span
    typeVarBindings <- traverse (typeVarBinding log) typeVarBindings'
    type'' <- type' log type'''
    pure (Language.PureScript.CST.TypeForall span forall' typeVarBindings dot type'')
  Language.PureScript.CST.TypeHole _ hole -> do
    let span = Span.type' type''''
    debug log "TypeHole" type'''' span
    pure (Language.PureScript.CST.TypeHole span hole)
  Language.PureScript.CST.TypeKinded _ type''' colons kind'' -> do
    let span = Span.type' type''''
    debug log "TypeKinded" type'''' span
    type'' <- type' log type'''
    kind' <- kind log kind''
    pure (Language.PureScript.CST.TypeKinded span type'' colons kind')
  Language.PureScript.CST.TypeOp _ type1' op type2' -> do
    let span = Span.type' type''''
    debug log "TypeOp" type'''' span
    type1 <- type' log type1'
    type2 <- type' log type2'
    pure (Language.PureScript.CST.TypeOp span type1 op type2)
  Language.PureScript.CST.TypeOpName _ op -> do
    let span = Span.type' type''''
    debug log "TypeOpName" type'''' span
    pure (Language.PureScript.CST.TypeOpName span op)
  Language.PureScript.CST.TypeParens _ wrapped'' -> do
    let span = Span.type' type''''
    debug log "TypeParens" type'''' span
    wrapped' <- wrapped log (type' log) wrapped''
    pure (Language.PureScript.CST.TypeParens span wrapped')
  Language.PureScript.CST.TypeRecord _ wrapped'' -> do
    let span = Span.type' type''''
    debug log "TypeRecord" type'''' span
    wrapped' <- wrapped log (row log) wrapped''
    pure (Language.PureScript.CST.TypeRecord span wrapped')
  Language.PureScript.CST.TypeRow _ wrapped'' -> do
    let span = Span.type' type''''
    debug log "TypeRow" type'''' span
    wrapped' <- wrapped log (row log) wrapped''
    pure (Language.PureScript.CST.TypeRow span wrapped')
  Language.PureScript.CST.TypeString _ sourceToken' string -> do
    let span = Span.type' type''''
    debug log "TypeString" type'''' span
    pure (Language.PureScript.CST.TypeString span sourceToken' string)
  Language.PureScript.CST.TypeVar _ var -> do
    let span = Span.type' type''''
    debug log "TypeVar" type'''' span
    pure (Language.PureScript.CST.TypeVar span var)
  Language.PureScript.CST.TypeWildcard _ wildcard -> do
    let span = Span.type' type''''
    debug log "TypeWildcard" type'''' span
    pure (Language.PureScript.CST.TypeWildcard span wildcard)

typeVarBinding ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.TypeVarBinding a ->
  IO (Language.PureScript.CST.TypeVarBinding Span.Span)
typeVarBinding log typeVarBinding' = case typeVarBinding' of
  Language.PureScript.CST.TypeVarKinded wrapped'' -> do
    let span = Span.typeVarBinding typeVarBinding'
    debug log "TypeVarKinded" typeVarBinding' span
    wrapped' <- wrapped log (labeledNameKind log) wrapped''
    pure (Language.PureScript.CST.TypeVarKinded wrapped')
  Language.PureScript.CST.TypeVarName name' -> do
    let span = Span.typeVarBinding typeVarBinding'
    debug log "TypeVarName" typeVarBinding' span
    pure (Language.PureScript.CST.TypeVarName name')

valueBindingFields ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.ValueBindingFields a ->
  IO (Language.PureScript.CST.ValueBindingFields Span.Span)
valueBindingFields log valueBindingFields' = case valueBindingFields' of
  Language.PureScript.CST.ValueBindingFields name' binders' guarded'' -> do
    let span = Span.valueBindingFields valueBindingFields'
    debug log "ValueBindingFields" valueBindingFields' span
    binders <- traverse (binder log) binders'
    guarded' <- guarded log guarded''
    pure (Language.PureScript.CST.ValueBindingFields name' binders guarded')

where' ::
  (Show a) =>
  Log.Handle ->
  Language.PureScript.CST.Where a ->
  IO (Language.PureScript.CST.Where Span.Span)
where' log where'' = case where'' of
  Language.PureScript.CST.Where expr'' letBindings' -> do
    let span = Span.where' where''
    debug log "Where" where'' span
    letBindings <- (traverse . traverse . traverse) (letBinding log) letBindings'
    expr' <- expr log expr''
    pure (Language.PureScript.CST.Where expr' letBindings)

wrapped ::
  (Show a) =>
  Log.Handle ->
  (a -> IO b) ->
  Language.PureScript.CST.Wrapped a ->
  IO (Language.PureScript.CST.Wrapped b)
wrapped log f wrapped' = case wrapped' of
  Language.PureScript.CST.Wrapped open a close -> do
    debug log "Wrapped" wrapped' (Span.wrapped wrapped')
    b <- f a
    pure (Language.PureScript.CST.Wrapped open b close)
