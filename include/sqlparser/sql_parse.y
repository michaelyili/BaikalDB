%{
// Copyright 2013 The ql Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSES/QL-LICENSE file.
// Copyright 2015 PingCAP, Inc.
// Modifications copyright (C) 2018, Baidu.com, Inc.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdio.h>
#define YY_DECL
#include "parser.h"
using parser::SqlParser;
using parser::InsertStmt;
using parser::Node;
using parser::Assignment;
using parser::ExprNode;
using parser::FuncType;
using parser::FuncExpr;
using parser::StmtNode;
using parser::String;
using parser::RowExpr;
using parser::ColumnName;
using parser::TableName;
using parser::PriorityEnum;
using parser::CreateTableStmt;

using namespace parser;
#include "sql_lex.flex.h"
#include "sql_parse.yacc.hh"
extern int sql_lex(YYSTYPE* yylval, YYLTYPE* yylloc, yyscan_t yyscanner, SqlParser* parser);
extern int sql_error(YYLTYPE* yylloc, yyscan_t yyscanner, SqlParser* parser, const char* s);
#define new_node(T) new(parser->arena.allocate(sizeof(T)))T()

%}

%defines
%output="sql_parse.yacc.cc"
%name-prefix="sql_"
%error-verbose
%lex-param {yyscan_t yyscanner}
%lex-param {SqlParser* parser}
%parse-param {yyscan_t yyscanner}
%parse-param {SqlParser* parser}

%token_table
%pure-parser
%verbose

%union
{
    int integer;
    Node* item;  // item can be used as list/array
    ExprNode* expr;
    StmtNode* stmt;
    Assignment* assign;
    String string;
    Vector<String>* string_list;
    IndexHint* index_hint;
    SelectStmtOpts* select_opts;
    SelectField* select_field;
    GroupByClause* group_by;
    OrderByClause* order_by;
    ByItem* by_item;
    LimitClause* limit;
}

%token 
/* The following tokens belong to ReservedKeyword. */
    ADD
    ALL
    ALTER
    ANALYZE
    AND
    AS
    ASC
    BETWEEN
    BIGINT
    BINARY
    BLOB
    BY
    CASCADE
    CASE
    CHANGE
    CHARACTER
    CHAR
    CHECK
    COLLATE
    COLUMN
    CONSTRAINT
    CONVERT
    CREATE
    CROSS
    CURRENT_TIMESTAMP
    CURRENT_USER
    DATABASE
    DATABASES
    DECIMAL
    DEFAULT
    DELAYED
    DELETE
    DESC
    DESCRIBE
    DISTINCT
    DISTINCTROW
    DIV
    DOUBLE
    DROP
    DUAL
    ELSE
    ENCLOSED
    ESCAPED
    EXISTS
    EXPLAIN
    FALSE
    FLOAT
    FOR
    FORCE
    FOREIGN
    FROM
    FULLTEXT
    GENERATED
    GRANT
    GROUP
    HAVING
    HIGH_PRIORITY
    IF
    IGNORE
    IN
    INDEX
    INFILE
    INNER
    INTEGER
    INTERVAL
    INTO
    IS
    INSERT
    INT
    INT1
    INT2
    INT3
    INT4
    INT8
    JOIN
    KEY
    KEYS
    KILL
    LEFT
    LIKE
    LIMIT
    LINES
    LOAD
    LOCALTIME
    LOCALTIMESTAMP
    LOCK
    LONGBLOB
    LONGTEXT
    LOW_PRIORITY
    MAXVALUE
    MEDIUMBLOB
    MEDIUMINT
    MEDIUMTEXT
    MOD
    NOT
    NO_WRITE_TO_BINLOG
    NULLX
    NUMERIC
    NVARCHAR
    ON
    OPTION
    OR
    ORDER
    OUTER
    PACK_KEYS
    PARTITION
    PRECISION
    PROCEDURE
    SHARD_ROW_ID_BITS
    RANGE
    READ
    REAL
    REFERENCES
    REGEXP
    RENAME
    REPEAT
    REPLACE
    RESTRICT
    REVOKE
    RIGHT
    RLIKE
    SELECT
    SET
    SHOW
    SMALLINT
    SQL
    SQL_CALC_FOUND_ROWS
    STARTING
    STRAIGHT_JOIN
    TABLE
    STORED
    TERMINATED
    THEN
    TINYBLOB
    TINYINT
    TINYTEXT
    TO
    TRIGGER
    TRUE
    UNIQUE
    UNION
    UNLOCK
    UNSIGNED
    UPDATE
    USAGE
    USE
    USING
    UTC_DATE
    UTC_TIMESTAMP
    UTC_TIME
    VALUES
    LONG
    VARCHAR
    VARBINARY
    VIRTUAL
    WHEN
    WHERE
    WRITE
    WITH
    XOR
    ZEROFILL
    NATURAL
%token<string>
    /* The following tokens belong to ReservedKeywork. */
    CURRENT_DATE
    BOTH
    CURRENT_TIME
    DAY_HOUR
    DAY_MICROSECOND
    DAY_MINUTE
    DAY_SECOND
    HOUR_MICROSECOND
    HOUR_MINUTE
    HOUR_SECOND
    LEADING
    MINUTE_MICROSECOND
    MINUTE_SECOND
    SECOND_MICROSECOND
    TRAILING
    YEAR_MONTH
    PRIMARY

%token<string>
    /* The following tokens belong to UnReservedKeyword. */
    ACTION
    AFTER
    ALWAYS
    ALGORITHM
    ANY
    ASCII
    AUTO_INCREMENT
    AVG_ROW_LENGTH
    AVG
    BEGINX
    WORK
    BINLOG
    BIT
    BOOLEAN
    BOOL
    BTREE
    BYTE
    CASCADED
    CHARSET
    CHECKSUM
    CLEANUP
    CLIENT
    COALESCE
    COLLATION
    COLUMNS
    COMMENT
    COMMIT
    COMMITTED
    COMPACT
    COMPRESSED
    COMPRESSION
    CONNECTION
    CONSISTENT
    DAY
    DATA
    DATE
    DATETIME
    DEALLOCATE
    DEFINER
    DELAY_KEY_WRITE
    DISABLE
    DO
    DUPLICATE
    DYNAMIC
    ENABLE
    END
    ENGINE
    ENGINES
    ENUM
    EVENT
    EVENTS
    ESCAPE
    EXCLUSIVE
    EXECUTE
    FIELDS
    FIRST
    FIXED
    FLUSH
    FORMAT
    FULL
    FUNCTION
    GRANTS
    HASH
    HOUR
    IDENTIFIED
    ISOLATION
    INDEXES
    INVOKER
    JSON
    KEY_BLOCK_SIZE
    LOCAL
    LESS
    LEVEL
    MASTER
    MICROSECOND
    MINUTE
    MODE
    MODIFY
    MONTH
    MAX_ROWS
    MAX_CONNECTIONS_PER_HOUR
    MAX_QUERIES_PER_HOUR
    MAX_UPDATES_PER_HOUR
    MAX_USER_CONNECTIONS
    MERGE
    MIN_ROWS
    NAMES
    NATIONAL
    NO
    NONE
    OFFSET
    ONLY
    PASSWORD
    PARTITIONS
    PLUGINS
    PREPARE
    PRIVILEGES
    PROCESS
    PROCESSLIST
    PROFILES
    QUARTER
    QUERY
    QUERIES
    QUICK
    RECOVER
    REDUNDANT
    RELOAD
    REPEATABLE
    REPLICATION
    REVERSE
    ROLLBACK
    ROUTINE
    ROW
    ROW_COUNT
    ROW_FORMAT
    SECOND
    SECURITY
    SEPARATOR
    SERIALIZABLE
    SESSION
    SHARE
    SHARED
    SIGNED
    SLAVE
    SNAPSHOT
    SQL_CACHE
    SQL_NO_CACHE
    START
    STATS_PERSISTENT
    STATUS
    SUPER
    SOME
    GLOBAL
    TABLES
    TEMPORARY
    TEMPTABLE
    TEXT
    THAN
    TIME
    TIMESTAMP
    TRACE
    TRANSACTION
    TRIGGERS
    TRUNCATE
    UNCOMMITTED
    UNKNOWN
    USER
    UNDEFINED
    VALUE
    VARIABLES
    VIEW
    WARNINGS
    WEEK
    YEAR

    /* The following tokens belong to builtin functions. */
    ADDDATE
    BIT_AND
    BIT_OR
    BIT_XOR
    CAST
    COUNT
    CURDATE
    CURTIME
    DATE_ADD
    DATE_SUB
    EXTRACT
    GROUP_CONCAT
    MAX
    MID
    MIN
    NOW
    POSITION
    SESSION_USER
    STD
    STDDEV
    STDDEV_POP
    STDDEV_SAMP
    SUBDATE
    SUBSTR
    SUBSTRING
    SUM
    SYSDATE
    SYSTEM_USER
    TRIM
    VARIANCE
    VAR_POP
    VAR_SAMP

%token EQ_OP ASSIGN_OP  MOD_OP  GE_OP  GT_OP LE_OP LT_OP NE_OP AND_OP OR_OP NOT_OP LS_OP RS_OP CHINESE_DOT
%token <string> IDENT 
%token <expr> STRING_LIT INTEGER_LIT DECIMAL_LIT

%type <string> 
    AllIdent 
    TableAsNameOpt 
    TableAsName 
    ConstraintKeywordOpt 
    IndexName 
    StringName 
    OptCharset 
    OptCollate
    DBName
    FunctionNameCurtime
    FunctionaNameCurdate
    FunctionNameDateArithMultiForms
    FunctionNameDateArith
    FunctionNameSubstring
    VarName
    AllIdentOrPrimary
    FieldAsNameOpt
    FieldAsName
    ShowDatabaseNameOpt
    ShowTableAliasOpt

%type <expr> 
    RowExprList
    RowExpr
    ColumnName
    ExprList
    Expr
    SimpleExpr
    FunctionCall
    Operators
    WhereClause
    WhereClauseOptional
    PredicateOp
    LikeEscapeOpt
    HavingClauseOptional
    BuildInFun
    SumExpr
    TimestampUnit
    FunctionCallNonKeyword
    FunctionCallKeyword
    TimeUnit
    FuncDatetimePrecListOpt
    TrimDirection
    DefaultValue
    ShowLikeOrWhereOpt

%type <item> 
    ColumnNameListOpt 
    ColumnNameList 
    TableName
    AssignmentList 
    ByList 
    IndexHintListOpt 
    IndexHintList 
    TableNameList
    SelectFieldList

%type <item> 
    TableElementList 
    TableElement 
    ColumnDef 
    ColumnOptionList 
    ColumnOption 
    Constraint 
    ConstraintElem 
    Type 
    NumericType 
    StringType 
    BlobType 
    TextType 
    DateAndTimeType 
    FieldOpt 
    FieldOpts 
    FloatOpt 
    Precision 
    StringList 
    TableOption 
    TableOptionList 
    CreateTableOptionListOpt
    DatabaseOption
    DatabaseOptionListOpt
    DatabaseOptionList
    VarAssignItem

%type <item> OnDuplicateKeyUpdate 
%type <item> 
    EscapedTableRef
    TableRef
    TableRefs 
    TableFactor
    JoinTable

%type <stmt> 
    MultiStmt
    Statement
    InsertStmt
    InsertValues
    ValueList
    UpdateStmt
    ReplaceStmt
    DeleteStmt
    SelectStmtBasic
    SelectStmtFromDual
    SelectStmtFromTable
    SelectStmt
    TruncateStmt 
    ShowStmt
    ShowTargetFilterable

%type <stmt> 
    CreateTableStmt
    DropTableStmt
    CreateDatabaseStmt
    DropDatabaseStmt
    StartTransactionStmt
    CommitTransactionStmt
    RollbackTransactionStmt
    SetStmt
    VarAssignList

%type <assign> Assignment
%type <integer> 
    PriorityOpt 
    IgnoreOptional 
    QuickOptional
    Order 
    IndexHintType 
    IndexHintScope 
    JoinType 
    IfNotExists 
    IfExists
    IntegerType 
    BooleanType 
    FixedPointType 
    FloatingPointType 
    BitValueType 
    OptFieldLen 
    FieldLen 
    OptBinary
    IsOrNot 
    InOrNot 
    LikeOrNot 
    BetweenOrNot 
    SelectStmtCalcFoundRows 
    SelectStmtSQLCache 
    SelectStmtStraightJoin 
    DistinctOpt  
    DefaultFalseDistinctOpt 
    BuggyDefaultFalseDistinctOpt
    SelectLockOpt
    GlobalScope
    OptFull

%type <string_list> IndexNameList 
%type <index_hint> IndexHint
%type <select_opts> SelectStmtOpts
%type <select_field> SelectField
%type <group_by> GroupBy GroupByOptional
%type <order_by> OrderBy OrderByOptional
%type <by_item> ByItem;
%type <limit> LimitClause;

%nonassoc empty

%nonassoc lowerThanSetKeyword
%nonassoc lowerThanKey
%nonassoc KEY

%left tableRefPriority
%left XOR OR
%left AND
%left EQ_OP NE_OP GE_OP GT_OP LE_OP LT_OP IS LIKE IN
%left '|'
%left '&'
%left LS_OP RS_OP
%left '+' '-'
%left '*' '/' MOD_OP  MOD
%left '^'
%right '~' NEG NOT NOT_OP
%right '.'
%nonassoc '('
%nonassoc QUICK

%%

// Parse Entrance
MultiStmt:
    Statement {
         parser->result.push_back($1);
    }
    | MultiStmt ';' Statement {
        parser->result.push_back($3);
    }
    | MultiStmt ';' {
        $$ = $1;
    }
    ;

Statement:
    InsertStmt
    | ReplaceStmt
    | UpdateStmt
    | DeleteStmt
    | TruncateStmt
    | CreateTableStmt
    | SelectStmt
    | DropTableStmt
    | CreateDatabaseStmt
    | DropDatabaseStmt
    | StartTransactionStmt
    | CommitTransactionStmt
    | RollbackTransactionStmt
    | SetStmt
    ;

InsertStmt:
    INSERT PriorityOpt IgnoreOptional IntoOpt TableName InsertValues OnDuplicateKeyUpdate {
        InsertStmt* insert = (InsertStmt*)$6;
        insert->priority = (PriorityEnum)$2;
        insert->is_ignore = (bool)$3;
        insert->table_name = (TableName*)$5;
        if ($7 != nullptr) {
            for (int i = 0; i < $7->children.size(); ++i) {
                (insert->on_duplicate).push_back((Assignment*)$7->children[i], parser->arena);
            }
        }
        $$ = insert;
    }
    ;

ReplaceStmt:
    REPLACE PriorityOpt IntoOpt TableName InsertValues {
        InsertStmt* insert = (InsertStmt*)$5;
        insert->priority = (PriorityEnum)$2;
        insert->is_replace = true;
        insert->table_name = (TableName*)$4;
        $$ = insert;
    }
    ;

PriorityOpt:
    {
        $$ = PE_NO_PRIORITY; 
    }
    | LOW_PRIORITY {
        $$ = PE_LOW_PRIORITY;
    }
    | HIGH_PRIORITY {
        $$ = PE_HIGH_PRIORITY;
    }
    | DELAYED {
        $$ = PE_DELAYED_PRIORITY;
    }
    ;
IgnoreOptional:
    {
        $$ = false; // false
    }
    | IGNORE {
        $$ = true; //true;
    }
    ;
QuickOptional:
    %prec empty {
        $$ = false;
    }
    | QUICK {
        $$ = true;
    }
    ;
IntoOpt:
    {}
    | INTO
    ;

InsertValues:
    '(' ColumnNameListOpt ')' values_sym ValueList {
        InsertStmt* insert = (InsertStmt*)$5;
        for (int i = 0; i < $2->children.size(); i++) {
            insert->columns.push_back((ColumnName*)($2->children[i]), parser->arena);
        }
        $$ = insert;
    }
    | values_sym ValueList {
        InsertStmt* insert = (InsertStmt*)$2;
        $$ = insert;
    }
    | SET AssignmentList {
        InsertStmt* insert = InsertStmt::New(parser->arena);
        RowExpr* row_expr = new_node(RowExpr);
        for (int i = 0; i < $2->children.size(); i++) {
            Assignment* assign = (Assignment*)$2->children[i];
            insert->columns.push_back(assign->name, parser->arena);
            row_expr->children.push_back(assign->expr, parser->arena);
        }
        insert->lists.push_back(row_expr, parser->arena);
        $$ = insert;
    }
    ;

values_sym:
    VALUE | VALUES
    ;
OnDuplicateKeyUpdate:
    {
        $$ = nullptr;    
    }
    | ON DUPLICATE KEY UPDATE AssignmentList {
        $$ = $5;
    }
    ;
AssignmentList:
    Assignment {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | AssignmentList ',' Assignment {
        $1->children.push_back($3, parser->arena);
        $$ = $1;
    }
    ;
Assignment:
    ColumnName EqAssign Expr {
        Assignment* assign = new_node(Assignment);
        assign->name =(ColumnName*)$1;
        assign->expr = $3;
        $$ = assign;
    }
    ;
EqAssign:
    EQ_OP | ASSIGN_OP
    ;

ValueList:
    RowExpr {
        InsertStmt* insert = InsertStmt::New(parser->arena);
        insert->lists.push_back((RowExpr*)$1, parser->arena);
        $$ = insert;
    }
    | ValueList ',' RowExpr {
        InsertStmt* insert = (InsertStmt*)$1;
        insert->lists.push_back((RowExpr*)$3, parser->arena);
        $$ = insert;
    }
    ;
// for IN_PREDICATE
RowExprList:
    RowExpr {
        RowExpr* row = new_node(RowExpr);
        row->children.reserve(10, parser->arena);
        row->children.push_back($1, parser->arena);
        $$ = row;
    }
    | RowExprList ',' RowExpr {
        RowExpr* row = (RowExpr*)$1;
        row->children.push_back($3, parser->arena);
        $$ = row;
    }
    ;
RowExpr:
    '(' ExprList ')' {
        $$ = (RowExpr*)$2;
    }
    ;
ExprList:
    Expr {
        RowExpr* row = new_node(RowExpr);
        row->children.reserve(10, parser->arena);
        row->children.push_back($1, parser->arena);
        $$ = row;
    } 
    | ExprList ',' Expr {
        RowExpr* row = (RowExpr*)$1;
        row->children.push_back($3, parser->arena);
        $$ = row;
    }
    ;
ColumnNameListOpt:
    /* empty */ {
        $$ = nullptr;
    }
    | ColumnNameList {
        $$ = $1;
    }
    ;

ColumnNameList:
    ColumnName {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | ColumnNameList ',' ColumnName {
        $1->children.push_back($3, parser->arena);
        $$ = $1;
    }
    ;

ColumnName:
    AllIdent {
        ColumnName* name = new_node(ColumnName);
        name->name = $1;
        $$ = name;
    }
    | AllIdent '.' AllIdent {
        ColumnName* name = new_node(ColumnName);
        name->table = $1;
        name->name = $3;
        $$ = name;
    }
    | AllIdent '.' AllIdent '.' AllIdent {
        ColumnName* name = new_node(ColumnName);
        name->db = $1;
        name->table = $3;
        name->name = $5;
        $$ = name;
    }
    ;

TableName:
    AllIdent {
        TableName* name = new_node(TableName);
        name->table = $1;
        $$ = name;
    }
    | AllIdent '.' AllIdent {
        TableName* name = new_node(TableName);
        name->db = $1;
        name->table = $3;
        $$ = name;
    } 
    ;

TableNameList:
    TableName {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | TableNameList ',' TableName{
        $1->children.push_back($3, parser->arena);
        $$ = $1;
    }
    ;

UpdateStmt:
    UPDATE PriorityOpt IgnoreOptional TableRef SET AssignmentList WhereClauseOptional OrderByOptional LimitClause {
        UpdateStmt* update = new_node(UpdateStmt);
        update->priority = (PriorityEnum)$2;
        update->is_ignore = $3;
        update->table_refs = $4;
        update->set_list.reserve($6->children.size(), parser->arena);
        for (int i = 0; i < $6->children.size(); i++) {
            Assignment* assign = (Assignment*)$6->children[i];
            update->set_list.push_back(assign, parser->arena);
        }
        update->where = $7;
        update->order = $8;
        update->limit = $9;
        $$ = update;
    }
    | UPDATE PriorityOpt IgnoreOptional TableRefs SET AssignmentList WhereClauseOptional {
        UpdateStmt* update = new_node(UpdateStmt);
        update->priority = (PriorityEnum)$2;
        update->is_ignore = $3;
        update->table_refs = $4;
        update->set_list.reserve($6->children.size(), parser->arena);
        for (int i = 0; i < $6->children.size(); i++) {
            Assignment* assign = (Assignment*)$6->children[i];
            update->set_list.push_back(assign, parser->arena);
        }
        update->where = $7;
        $$ = update;
    }
    ;
TruncateStmt:
    TRUNCATE TABLE TableName {
        TruncateStmt* truncate_stmt = new_node(TruncateStmt);
        truncate_stmt->table_name = (TableName*)$3;
        $$ = truncate_stmt;
    }
    | TRUNCATE TableName {
        TruncateStmt* truncate_stmt = new_node(TruncateStmt);
        truncate_stmt->table_name = (TableName*)$2;
        $$ = truncate_stmt;
    }
    ;
DeleteStmt:
    DELETE PriorityOpt QuickOptional IgnoreOptional FROM TableName WhereClauseOptional OrderByOptional LimitClause {
        DeleteStmt* delete_stmt = new_node(DeleteStmt);
        delete_stmt->priority = (PriorityEnum)$2;
        delete_stmt->is_quick = $3;
        delete_stmt->is_ignore = (bool)$4;
        delete_stmt->from_table = $6;
        delete_stmt->where = $7;
        delete_stmt->order = $8;
        delete_stmt->limit = $9;
        $$ = delete_stmt;
    }
    | DELETE PriorityOpt QuickOptional IgnoreOptional TableNameList FROM TableRefs WhereClauseOptional {
        DeleteStmt* delete_stmt = new_node(DeleteStmt);
        delete_stmt->priority = (PriorityEnum)$2;
        delete_stmt->is_quick = (bool)$3;
        delete_stmt->is_ignore = (bool)$4;
        for (int i = 0; i < $5->children.size(); i++) {
            delete_stmt->delete_table_list.push_back((TableName*)$5->children[i], parser->arena);
        }
        delete_stmt->from_table = $7;
        delete_stmt->where = $8;
        $$ = delete_stmt;
    }
    ;

TableRefs:
    EscapedTableRef {
        $$ = $1;    
    }
    | TableRefs ',' EscapedTableRef {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $3;
        $$ = join_node;    
    }
    ;
EscapedTableRef:
    TableRef %prec lowerThanSetKeyword {
        $$ = $1; 
    }
    | '{' AllIdent TableRef '}' {
        $$ = $3;
    }
    ;
TableRef:
    TableFactor {
        $$ = $1; 
    }
    | JoinTable {
        $$ = $1;
    }
    ;

TableFactor:
    TableName TableAsNameOpt IndexHintListOpt {
        TableSource* table_source = new_node(TableSource);
        table_source->table_name = (TableName*)$1;
        table_source->as_name = $2;
        if ($3 != nullptr) {
            for (int i = 0; i < $3->children.size(); i++) {
                table_source->index_hints.push_back((IndexHint*)($3->children[i]), parser->arena);
            }
        }
        $$ = table_source;
    }
    | '(' TableRefs ')' {
        $$ = $2; 
    }
    ;

TableAsNameOpt:
    {
        $$ = nullptr;
    }
    | TableAsName {
        $$ = $1; 
    }
    ;

TableAsName:
    AllIdent {
        $$ = $1;
    }
    | AS AllIdent {
        $$ = $2;
    }
    ;

IndexHintListOpt: 
    {
        $$ = nullptr;                
    }
    | IndexHintList {
        $$ = $1; 
    }
    ;

IndexHintList:
    IndexHint {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | IndexHintList IndexHint {
        $1->children.push_back($2, parser->arena);
        $$ = $1;
    }
    ;

IndexHint:
    IndexHintType IndexHintScope '(' IndexNameList ')' {
        IndexHint* index_hint = new_node(IndexHint);
        index_hint->hint_type = (IndexHintType)$1;
        index_hint->hint_scope = (IndexHintScope)$2;
        if ($4 != nullptr) {
            for (int i = 0; i < $4->size(); ++i) {
                index_hint->index_name_list.push_back((*$4)[i], parser->arena); 
            }
        }
        $$ = index_hint;
    }
    ;

IndexHintType:
    USE KeyOrIndex {
        $$ = IHT_HINT_USE; 
    }
    | IGNORE KeyOrIndex {
        $$ = IHT_HINT_IGNORE;
    }
    | FORCE KeyOrIndex {
        $$ = IHT_HINT_FORCE;
    }
    ;

KeyOrIndex: 
    KEY | INDEX
    ;

KeyOrIndexOpt:
    {
    }
    | KeyOrIndex
    ;

IndexHintScope:
    {
        $$ = IHS_HINT_SCAN;
    }
    | FOR JOIN {
        $$ = IHS_HINT_JOIN;
    }
    | FOR ORDER BY {
        $$ = IHS_HINT_ORDER_BY;
    }
    | FOR GROUP BY {
        $$ = IHS_HINT_GROUP_BY;
    }
    ;

IndexNameList: {
        $$ = nullptr; 
    }
    | AllIdentOrPrimary {
        Vector<String>* string_list = new_node(Vector<String>);
        string_list->reserve(10, parser->arena);
        string_list->push_back($1, parser->arena);
        $$ = string_list;
    }
    | IndexNameList ',' AllIdentOrPrimary {
        $1->push_back($3, parser->arena);
        $$ = $1;
    }
    ;

AllIdentOrPrimary: 
    AllIdent{
        $$ = $1;
    }
    | PRIMARY {
        $$ = $1;
    }
    ;
JoinTable:
    /* Use %prec to evaluate production TableRef before cross join */
    TableRef CrossOpt TableRef %prec tableRefPriority {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $3;
        $$ = join_node;
    }
    | TableRef CrossOpt TableRef ON Expr {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $3;
        join_node->expr = $5;
        $$ = join_node;
    }
    | TableRef CrossOpt TableRef USING '(' ColumnNameList ')' {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left =  $1;
        join_node->right = $3;
        for (int i = 0; i < $6->children.size(); i++) {
            join_node->using_col.push_back((ColumnName*)($6->children[i]), parser->arena);
        }
        $$ = join_node;
    }
    | TableRef JoinType OuterOpt JOIN TableRef ON Expr {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left =  $1;
        join_node->join_type = (JoinType)$2; 
        join_node->right = $5;
        join_node->expr = $7;
        $$ = join_node;
    }
    | TableRef JoinType OuterOpt JOIN TableRef USING '(' ColumnNameList ')' {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->join_type = (JoinType)$2; 
        join_node->right = $5;
        for (int i = 0; i < $8->children.size(); i++) {
            join_node->using_col.push_back((ColumnName*)($8->children[i]), parser->arena);
        }
        $$ = join_node;
    }
    | TableRef STRAIGHT_JOIN TableRef {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $3;
        join_node->is_straight = true;
        $$ = join_node;
    }
    | TableRef STRAIGHT_JOIN TableRef ON Expr {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $3;
        join_node->is_straight = true;
        join_node->expr = $5;
        $$ = join_node;
    }
    | TableRef NATURAL JOIN TableRef {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $4;
        join_node->is_natural = true;
        $$ = join_node;
    }
    | TableRef NATURAL INNER JOIN TableRef {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->right = $5;
        join_node->is_natural = true;
        $$ = join_node;
    }
    | TableRef NATURAL JoinType OuterOpt JOIN TableRef {
        JoinNode* join_node = new_node(JoinNode);
        join_node->left = $1;
        join_node->join_type = (JoinType)$3;
        join_node->right = $6;
        join_node->is_natural = true;
        $$ = join_node;
    }
    ;

JoinType:
    LEFT {
        $$ = JT_LEFT_JOIN; 
    }
    | RIGHT {
        $$ = JT_RIGHT_JOIN;
    }
    ;
OuterOpt:
    {}
    | OUTER
    ;

CrossOpt:
    JOIN | CROSS JOIN | INNER JOIN
    ;

LimitClause:
    {
        $$ = nullptr;
    }
    | LIMIT INTEGER_LIT {
        LimitClause* limit = new_node(LimitClause);
        limit->count = ((LiteralExpr*)$2)->_u.int64_val;
        $$ = limit;
    }
    | LIMIT INTEGER_LIT ',' INTEGER_LIT {
        LimitClause* limit = new_node(LimitClause);
        limit->offset = ((LiteralExpr*)$2)->_u.int64_val;
        limit->count = ((LiteralExpr*)$4)->_u.int64_val;
        $$ = limit;
    }
    ;
WhereClause:
    WHERE Expr {
        $$ = $2;
    }
    ;
WhereClauseOptional: 
    {
        $$ = nullptr;
    }
    | WhereClause {
        $$ = $1;
    }
    ;
HavingClauseOptional: 
    {
        $$ = nullptr;
    }
    | HAVING Expr {
        $$ = $2;
    }
    ;
OrderByOptional: 
    {
        $$ = nullptr; 
    }
    | OrderBy {
        $$ = $1;
    }
    ;
OrderBy:
    ORDER BY ByList {
        OrderByClause* order = new_node(OrderByClause);
        for (int i = 0; i < $3->children.size(); i++) {
            order->items.push_back((ByItem*)($3->children[i]), parser->arena);
        }
        $$ = order;
    }
    ;

GroupByOptional:
    {
        $$ = nullptr;
    }
    | GroupBy {
        $$ = $1;
    }
    ;
GroupBy:
    GROUP BY ByList 
    {
        GroupByClause* group = new_node(GroupByClause);
        for (int i = 0; i < $3->children.size(); ++i) {
            group->items.push_back((ByItem*)$3->children[i], parser->arena);
        }
        $$ = group;
    }
    ;
ByList:
    ByItem {
        Node* arr = new_node(Node);
        arr->children.push_back($1, parser->arena);
        $$ = arr;
    }
    | ByList ',' ByItem {
        $1->children.push_back($3, parser->arena);
        $$ = $1;
    }
    ;
ByItem:
    Expr Order 
    {
        ByItem* item = new_node(ByItem);
        item->expr = $1;
        item->is_desc = $2;
        $$ = item;
    }

Order:
    /* EMPTY */ {
        $$ = false; // ASC by default
    }
    | ASC {
        $$ = false;
    }
    | DESC {
        $$ = true;
    }
    ;
SelectStmtOpts:
    DefaultFalseDistinctOpt PriorityOpt SelectStmtStraightJoin  SelectStmtSQLCache SelectStmtCalcFoundRows {
        $$ = new_node(SelectStmtOpts);
        $$->distinct = $1;
        $$->priority = (PriorityEnum)$2;
        $$->straight_join = $3;
        $$->sql_cache = $4;
        $$->calc_found_rows = $5;
    }
    ;
SelectStmtBasic:
    SELECT SelectStmtOpts SelectFieldList {
        SelectStmt* select = new_node(SelectStmt);
        select->select_opt = $2;
        for (int i = 0; i < $3->children.size(); ++i) {
            select->fields.push_back((SelectField*)$3->children[i], parser->arena);
        }
        $$ = select;
    }
    ;
SelectStmtFromDual:
    SelectStmtBasic FromDual WhereClauseOptional {
        SelectStmt* select = (SelectStmt*)$1;
        select->where = $3;
        $$ = select;
    }
    ;
SelectStmtFromTable:
    SelectStmtBasic FROM TableRefs WhereClauseOptional GroupByOptional HavingClauseOptional {
        SelectStmt* select = (SelectStmt*)$1;
        select->table_refs = $3;
        select->where = $4;
        select->group = $5;
        select->having = $6;
        $$ = select;
    } 
    ;

SelectStmt:
    SelectStmtBasic OrderByOptional LimitClause SelectLockOpt {
        SelectStmt* select = (SelectStmt*)$1;
        select->order = $2;
        select->limit = $3;
        select->lock = (SelectLock)$4;
        $$ = select;
    }
    | SelectStmtFromDual LimitClause SelectLockOpt {
        SelectStmt* select = (SelectStmt*)$1;
        select->limit = $2;
        select->lock = (SelectLock)$3;
        $$ = select;
    }
    | SelectStmtFromTable OrderByOptional LimitClause SelectLockOpt {
        SelectStmt* select = (SelectStmt*)$1;
        select->order = $2;
        select->limit = $3;
        select->lock = (SelectLock)$4;
        $$ = select;
    }
    ;
SelectLockOpt:
    /* empty */
    {
        $$ = SL_NONE;
    }
    | FOR UPDATE {
        $$ = SL_FOR_UPDATE;
    }
    | LOCK IN SHARE MODE {
        $$ = SL_IN_SHARE;
    }
    ;
FromDual:
    FROM DUAL
    ;

SelectStmtCalcFoundRows: {
        $$ = false;
    }
    | SQL_CALC_FOUND_ROWS {
        $$ = true;
    }
    ;
SelectStmtSQLCache:
    {
        $$ = false;
    }
    | SQL_CACHE {
        $$ = true;
    }
    | SQL_NO_CACHE {
        $$ = false;
    }
    ;
SelectStmtStraightJoin:
    {
        $$ = false;
    }
    | STRAIGHT_JOIN {
        $$ = true;
    }
    ;
SelectFieldList:
    SelectField {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | SelectFieldList ',' SelectField {
        $1->children.push_back($3, parser->arena);
        $$ = $1;
    }
    ;
SelectField:
    '*' {
       SelectField* select_field = new_node(SelectField);
       select_field->wild_card = new_node(WildCardField);
       select_field->wild_card->table_name.set_null();
       select_field->wild_card->db_name.set_null();
       $$ = select_field;
    }
    | AllIdent '.' '*' {
        SelectField* select_field = new_node(SelectField);
        select_field->wild_card = new_node(WildCardField);
        select_field->wild_card->table_name = $1;
        select_field->wild_card->db_name.set_null();
        $$ = select_field;
    }
    | AllIdent '.' AllIdent '.' '*' {
        SelectField* select_field = new_node(SelectField);
        select_field->wild_card = new_node(WildCardField);
        select_field->wild_card->db_name = $1;
        select_field->wild_card->table_name = $3;
        $$ = select_field;
    }
    | Expr FieldAsNameOpt {
        SelectField* select_field = new_node(SelectField);
        select_field->expr = $1;
        select_field->as_name = $2;
        $$ = select_field;
    }
    | '{' AllIdent Expr '}' FieldAsNameOpt {
        SelectField* select_field = new_node(SelectField);
        select_field->expr = $3;
        select_field->as_name = $5;
        $$ = select_field;
    }
    ;
FieldAsNameOpt:
    /* EMPTY */
    {
        $$ = nullptr;
    }
    | FieldAsName {
        $$ = $1;
    }

FieldAsName:
    AllIdent {
        $$ = $1;
    }
    | AS AllIdent {
        $$ = $2;
    }
    | STRING_LIT {
        $$ = ((LiteralExpr*)$1)->_u.str_val;
    }
    | AS STRING_LIT {
        $$ = ((LiteralExpr*)$2)->_u.str_val;
    }
    ;

/*Expr*/
Expr:
    Operators { $$ = $1;}
    | PredicateOp { $$ = $1;}
    | SimpleExpr { $$ = $1;}
    ;

FunctionCall:
    BuildInFun {
        $$ = $1;
    }
    | IDENT '(' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun;
    }
    | IDENT '(' ExprList ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children = $3->children;
        $$ = fun;
    }
    ;

BuildInFun:
    SumExpr
    | FunctionCallNonKeyword 
    | FunctionCallKeyword
    ;
FuncDatetimePrecListOpt:
    {
        $$ = nullptr;
    }
    | INTEGER_LIT {
        $$ = $1;        
    } 
    ;
FunctionNameDateArithMultiForms:
    ADDDATE | SUBDATE
    ;
FunctionNameDateArith:
     DATE_ADD | DATE_SUB
     ;
FunctionNameSubstring:
    SUBSTR | SUBSTRING
    ;

TimestampUnit:
    MICROSECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | SECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | MINUTE {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | HOUR {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | DAY {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | WEEK {
        $$ = LiteralExpr::make_string($1, parser->arena);
    } 
    | MONTH {
        $$ = LiteralExpr::make_string($1, parser->arena);
    } 
    | QUARTER {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | YEAR {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    ;

TimeUnit:
    MICROSECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | SECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    } 
    | MINUTE {
        $$ = LiteralExpr::make_string($1, parser->arena);
    } 
    | HOUR {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | DAY {
        $$ = LiteralExpr::make_string($1, parser->arena);
    } 
    | WEEK {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | MONTH {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | QUARTER {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | YEAR {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | SECOND_MICROSECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | MINUTE_MICROSECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | MINUTE_SECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | HOUR_MICROSECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | HOUR_SECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | HOUR_MINUTE {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | DAY_MICROSECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | DAY_SECOND {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | DAY_MINUTE {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | DAY_HOUR {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | YEAR_MONTH {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    ;

TrimDirection:
    BOTH {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | LEADING {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    | TRAILING {
        $$ = LiteralExpr::make_string($1, parser->arena);
    }
    ;

FunctionNameCurtime:
    CURTIME | CURRENT_TIME
;

FunctionaNameCurdate:
    CURDATE | CURRENT_DATE
;

FunctionCallNonKeyword: 
    FunctionNameCurtime '(' FuncDatetimePrecListOpt ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        if ($3 != nullptr) {
            fun->children.push_back($3, parser->arena);
        }
        $$ = fun;
    }
    | CURRENT_TIME {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | FunctionaNameCurdate '(' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | CURRENT_DATE {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | SYSDATE '(' FuncDatetimePrecListOpt ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        if ($3 != nullptr) {
            fun->children.push_back($3, parser->arena);
        }
        $$ = fun;
    }
    | NOW '(' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | FunctionNameDateArithMultiForms '(' Expr ',' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        LiteralExpr* day_expr = LiteralExpr::make_string("DAY", parser->arena);
        fun->children.push_back(day_expr, parser->arena);
        $$ = fun;
    }
    | FunctionNameDateArithMultiForms '(' Expr ',' INTERVAL Expr TimeUnit ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($6, parser->arena);
        fun->children.push_back($7, parser->arena);
        $$ = fun;
    }
    | FunctionNameDateArith '(' Expr ',' INTERVAL Expr TimeUnit ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($6, parser->arena);
        fun->children.push_back($7, parser->arena);
        $$ = fun;
    }
    | USER '(' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | SYSTEM_USER '(' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | SESSION_USER '(' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        $$ = fun; 
    }
    | EXTRACT '(' TimeUnit FROM Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        $$ = fun;
    }
    | POSITION '(' Expr IN Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        $$ = fun;
    }
    | FunctionNameSubstring '(' Expr ',' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = "substr";
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        $$ = fun;
    }
    | FunctionNameSubstring '(' Expr FROM Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = "substr";
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        $$ = fun;
    }
    | FunctionNameSubstring '(' Expr ',' Expr ',' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = "substr";
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        fun->children.push_back($7, parser->arena);
        $$ = fun;
    }
    | FunctionNameSubstring '(' Expr FROM Expr FOR Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = "substr";
        fun->children.push_back($3, parser->arena);
        fun->children.push_back($5, parser->arena);
        fun->children.push_back($7, parser->arena);
        $$ = fun;
    }
    | TRIM '(' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    | TRIM '(' Expr FROM Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($5, parser->arena);
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    | TRIM '(' TrimDirection FROM Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($5, parser->arena);
        fun->children.push_back(nullptr, parser->arena);
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    | TRIM '(' TrimDirection Expr FROM Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = $1;
        fun->children.push_back($6, parser->arena);
        fun->children.push_back($4, parser->arena);
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    ;
FunctionCallKeyword:
    VALUES '(' ColumnName ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->fn_name = "values";
        fun->func_type = FT_VALUES;
        fun->children.push_back($3, parser->arena);
        $$ = fun; 
    }
    ;
SumExpr:
    AVG '(' BuggyDefaultFalseDistinctOpt Expr')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = $3;
        fun->children.push_back($4, parser->arena);
        $$ = fun;    
    }
    | BIT_AND '(' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($3, parser->arena);
        $$ = fun; 
    }
    | BIT_AND '(' ALL Expr ')' { 
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    | BIT_OR '(' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    | BIT_OR '(' ALL Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($4, parser->arena);
        $$ = fun; 
    }
    | BIT_XOR '(' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    | BIT_XOR '(' ALL Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    | COUNT '(' DistinctKwd Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = true;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    | COUNT '(' ALL Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    | COUNT '(' Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false;
        fun->children.push_back($3, parser->arena);
        $$ = fun;
    }
    | COUNT '(' '*' ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = false; 
        fun->is_star = true;
        $$ = fun;
    }
    | MAX '(' BuggyDefaultFalseDistinctOpt Expr')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = $3;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    | MIN '(' BuggyDefaultFalseDistinctOpt Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = $3;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    | SUM '(' BuggyDefaultFalseDistinctOpt Expr ')' {
        FuncExpr* fun = new_node(FuncExpr);
        fun->func_type = FT_AGG;
        fun->fn_name = $1;
        fun->distinct = $3;
        fun->children.push_back($4, parser->arena);
        $$ = fun;
    }
    ;

DistinctKwd:
    DISTINCT
    | DISTINCTROW
    ;

DistinctOpt:
    ALL {
        $$ = false;
    }
    | DistinctKwd {
        $$ = true;
    }
    ;

DefaultFalseDistinctOpt:
    {
        $$ = false;
    }
    | DistinctOpt
    ;

BuggyDefaultFalseDistinctOpt:
    DefaultFalseDistinctOpt
    | DistinctKwd ALL {
        $$ = true;
    }
    ;

AllIdent:
    IDENT {}
    // UnReservedKeyword 
    | ACTION
    | AFTER
    | ALWAYS
    | ALGORITHM
    | ANY
    | ASCII
    | AUTO_INCREMENT
    | AVG_ROW_LENGTH
    | AVG
    | BEGINX
    | WORK
    | BINLOG
    | BIT
    | BOOLEAN
    | BOOL
    | BTREE
    | BYTE
    | CASCADED
    | CHARSET
    | CHECKSUM
    | CLEANUP
    | CLIENT
    | COALESCE
    | COLLATION
    | COLUMNS
    | COMMENT
    | COMMIT
    | COMMITTED
    | COMPACT
    | COMPRESSED
    | COMPRESSION
    | CONNECTION
    | CONSISTENT
    | DAY
    | DATA
    | DATE
    | DATETIME
    | DEALLOCATE
    | DEFINER
    | DELAY_KEY_WRITE
    | DISABLE
    | DO
    | DUPLICATE
    | DYNAMIC
    | ENABLE
    | END
    | ENGINE
    | ENGINES
    | ENUM
    | EVENT
    | EVENTS
    | ESCAPE
    | EXCLUSIVE
    | EXECUTE
    | FIELDS
    | FIRST
    | FIXED
    | FLUSH
    | FORMAT
    | FULL
    | FUNCTION
    | GRANTS
    | HASH
    | HOUR
    | IDENTIFIED
    | ISOLATION
    | INDEXES
    | INVOKER
    | JSON
    | KEY_BLOCK_SIZE
    | LOCAL
    | LESS
    | LEVEL
    | MASTER
    | MICROSECOND
    | MINUTE
    | MODE
    | MODIFY
    | MONTH
    | MAX_ROWS
    | MAX_CONNECTIONS_PER_HOUR
    | MAX_QUERIES_PER_HOUR
    | MAX_UPDATES_PER_HOUR
    | MAX_USER_CONNECTIONS
    | MERGE
    | MIN_ROWS
    | NAMES
    | NATIONAL
    | NO
    | NONE
    | OFFSET
    | ONLY
    | PASSWORD
    | PARTITIONS
    | PLUGINS
    | PREPARE
    | PRIVILEGES
    | PROCESS
    | PROCESSLIST
    | PROFILES
    | QUARTER
    | QUERY
    | QUERIES
    | QUICK
    | RECOVER
    | REDUNDANT
    | RELOAD
    | REPEATABLE
    | REPLICATION
    | REVERSE
    | ROLLBACK
    | ROUTINE
    | ROW
    | ROW_COUNT
    | ROW_FORMAT
    | SECOND
    | SECURITY
    | SEPARATOR
    | SERIALIZABLE
    | SESSION
    | SHARE
    | SHARED
    | SIGNED
    | SLAVE
    | SNAPSHOT
    | SQL_CACHE
    | SQL_NO_CACHE
    | START
    | STATS_PERSISTENT
    | STATUS
    | SUPER
    | SOME
    | GLOBAL
    | TABLES
    | TEMPORARY
    | TEMPTABLE
    | TEXT
    | THAN
    | TIME
    | TIMESTAMP
    | TRACE
    | TRANSACTION
    | TRIGGERS
    | TRUNCATE
    | UNCOMMITTED
    | UNKNOWN
    | USER
    | UNDEFINED
    | VALUE
    | VARIABLES
    | VIEW
    | WARNINGS
    | WEEK
    | YEAR
    /* builtin functions. */
    | ADDDATE
    | BIT_AND
    | BIT_OR
    | BIT_XOR
    | CAST
    | COUNT
    | CURDATE
    | CURTIME
    | DATE_ADD
    | DATE_SUB
    | EXTRACT
    | GROUP_CONCAT
    | MAX
    | MID
    | MIN
    | NOW
    | POSITION
    | SESSION_USER
    | STD
    | STDDEV
    | STDDEV_POP
    | STDDEV_SAMP
    | SUBDATE
    | SUBSTR
    | SUBSTRING
    | SUM
    | SYSDATE
    | SYSTEM_USER
    | TRIM
    | VARIANCE
    | VAR_POP
    | VAR_SAMP
    ;

SimpleExpr:
    NULLX {
        $$ = LiteralExpr::make_null(parser->arena);
    }
    | TRUE {
        $$ = LiteralExpr::make_true(parser->arena);
    }
    | FALSE {
        $$ = LiteralExpr::make_false(parser->arena);
    }
    | INTEGER_LIT {}
    | DECIMAL_LIT {}
    | STRING_LIT {}
    | ColumnName {}
    | RowExpr {}
    | FunctionCall {}
    | '-' SimpleExpr %prec NEG {
        $$ = FuncExpr::new_unary_op_node(FT_UMINUS, $2, parser->arena);
    }
    | '+' SimpleExpr %prec NEG { 
        $$ = $2;
    }
    | NOT SimpleExpr {
        $$ = FuncExpr::new_unary_op_node(FT_LOGIC_NOT, $2, parser->arena);
    }
    | NOT_OP SimpleExpr {
        $$ = FuncExpr::new_unary_op_node(FT_LOGIC_NOT, $2, parser->arena);
    }
    | '~' SimpleExpr {
        $$ = FuncExpr::new_unary_op_node(FT_BIT_NOT, $2, parser->arena);
    }
    | '(' Expr ')' {
        $$ = $2;
    }
    ;

Operators:
    Expr '+' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_ADD, $1, $3, parser->arena);
    }
    | Expr '-' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_MINUS, $1, $3, parser->arena);
    }
    | Expr '*' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_MULTIPLIES, $1, $3, parser->arena);
    }
    | Expr '/' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_DIVIDES, $1, $3, parser->arena);
    }
    | Expr MOD Expr {
        $$ = FuncExpr::new_binary_op_node(FT_MOD, $1, $3, parser->arena);
    } 
    | Expr MOD_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_MOD, $1, $3, parser->arena);
    } 
    | Expr LS_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_LS, $1, $3, parser->arena);
    }
    | Expr RS_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_RS, $1, $3, parser->arena);
    }
    | Expr '&' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_BIT_AND, $1, $3, parser->arena);
    }
    | Expr '|' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_BIT_OR, $1, $3, parser->arena);
    }
    | Expr '^' Expr {
        $$ = FuncExpr::new_binary_op_node(FT_BIT_XOR, $1, $3, parser->arena);
    }
    | Expr EQ_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_EQ, $1, $3, parser->arena);
    }
    | Expr NE_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_NE, $1, $3, parser->arena);
    }
    | Expr GT_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_GT, $1, $3, parser->arena);
    }
    | Expr GE_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_GE, $1, $3, parser->arena);
    } 
    | Expr LT_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_LT, $1, $3, parser->arena);
    }
    | Expr LE_OP Expr {
        $$ = FuncExpr::new_binary_op_node(FT_LE, $1, $3, parser->arena);
    }
    | Expr AND Expr {
        $$ = FuncExpr::new_binary_op_node(FT_LOGIC_AND, $1, $3, parser->arena);
    }
    | Expr OR Expr {
        $$ = FuncExpr::new_binary_op_node(FT_LOGIC_OR, $1, $3, parser->arena);
    }
    | Expr XOR Expr {
        $$ = FuncExpr::new_binary_op_node(FT_LOGIC_XOR, $1, $3, parser->arena);
    }
    ;

PredicateOp:
    Expr IsOrNot NULLX %prec IS {
        FuncExpr* fun = FuncExpr::new_unary_op_node(FT_IS_NULL, $1, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    | Expr IsOrNot TRUE %prec IS {
        FuncExpr* fun = FuncExpr::new_unary_op_node(FT_IS_TRUE, $1, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    | Expr IsOrNot FALSE %prec IS {
        FuncExpr* fun = FuncExpr::new_unary_op_node(FT_IS_TRUE, $1, parser->arena);
        fun->is_not = !$2;
        $$ = fun;
    }
    | Expr IsOrNot UNKNOWN %prec IS {
        FuncExpr* fun = FuncExpr::new_unary_op_node(FT_IS_UNKNOWN, $1, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    | SimpleExpr InOrNot '(' ExprList ')' %prec IN {
        FuncExpr* fun = FuncExpr::new_binary_op_node(FT_IN, $1, $4, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    | RowExpr InOrNot '(' RowExprList ')' %prec IN {
        FuncExpr* fun = FuncExpr::new_binary_op_node(FT_IN, $1, $4, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    //| Expr EXISTS SubSelect {
    //}
    | SimpleExpr LikeOrNot SimpleExpr LikeEscapeOpt %prec LIKE {
        FuncExpr* fun = FuncExpr::new_ternary_op_node(FT_LIKE, $1, $3, $4, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    | SimpleExpr BetweenOrNot SimpleExpr AND SimpleExpr {
        FuncExpr* fun = FuncExpr::new_ternary_op_node(FT_BETWEEN, $1, $3, $5, parser->arena);
        fun->is_not = $2;
        $$ = fun;
    }
    ;
IsOrNot:
    IS {
        $$ = false;
    }
    | IS NOT {
        $$ = true;
    }
    ;
InOrNot:
    IN {
        $$ = false;
    }
    | NOT IN {
        $$ = true;
    }
    ;
LikeOrNot:
    LIKE {
        $$ = false;
    }
    | NOT LIKE {
        $$ = true;
    }
    ;
LikeEscapeOpt:
    {
        $$ = LiteralExpr::make_string("'\\'", parser->arena);
    }
    |   "ESCAPE" STRING_LIT {
        $$ = $2;
    }
    ;
BetweenOrNot:
    BETWEEN {
        $$ = false;
    }
    | NOT BETWEEN {
        $$ = true;
    }
    ;


/*create table statement*/
// TODO: create table xx like xx
CreateTableStmt:
    CREATE TABLE IfNotExists TableName '(' TableElementList ')' CreateTableOptionListOpt
    {
        CreateTableStmt* stmt = new_node(CreateTableStmt);
        stmt->if_not_exist = $3;
        stmt->table_name = (TableName*)($4);
        for (int idx = 0; idx < $6->children.size(); ++idx) {
            if ($6->children[idx]->node_type == NT_COLUMN_DEF) {
                stmt->columns.push_back((ColumnDef*)($6->children[idx]), parser->arena);
            } else if ($6->children[idx]->node_type == NT_CONSTRAINT) {
                stmt->constraints.push_back((Constraint*)($6->children[idx]), parser->arena);
            }
        }
        for (int idx = 0; idx < $8->children.size(); ++idx) {
            stmt->options.push_back((TableOption*)($8->children[idx]), parser->arena);
        }
        //stmt->options = $8->children;
        $$ = stmt;
    }
    ;

IfNotExists:
    {
        $$ = false;
    }
    | IF NOT EXISTS
    {
        $$ = true;
    }
    ;

IfExists:
    {
        $$ = false;
    }
    | IF EXISTS
    {
        $$ = true;
    }
    ;

TableElementList:
    TableElement
    {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        if ($1 != nullptr) {
            list->children.push_back($1, parser->arena);
        }
        $$ = list;
    }
    | TableElementList ',' TableElement
    {
        if ($3 != nullptr) {
            $1->children.push_back($3, parser->arena);
        }
        $$ = $1;
    }
    ;

TableElement:
    ColumnDef
    {
        $$ = $1;
    }
    | Constraint
    {
        $$ = $1;
    }
    | CHECK '(' Expr ')'
    {
        /* Nothing to do now */
        $$ = nullptr;
    }
    ;

ColumnDef:
    ColumnName Type ColumnOptionList
    {
        ColumnDef* column = new_node(ColumnDef);
        column->name = (ColumnName*)$1;
        column->type = (FieldType*)$2;
        for (int idx = 0; idx < $3->children.size(); ++idx) {
            column->options.push_back((ColumnOption*)($3->children[idx]), parser->arena);
        }
        $$ = column;
    }
    ;

ColumnOptionList:
    {
        $$ = new_node(Node);
    }
    | ColumnOptionList ColumnOption
    {
        $1->children.push_back($2, parser->arena);
        $$ = $1;
    }
    ;

ColumnOption:
    NOT NULLX
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_NOT_NULL;
        $$ = option;
    }
    | NULLX
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_NULL;
        $$ = option;
    }
    | AUTO_INCREMENT
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_AUTO_INC;
        $$ = option;
    }
    | PrimaryOpt KEY
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_PRIMARY_KEY;
        $$ = option;
    }
    | UNIQUE %prec lowerThanKey
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_UNIQ_KEY;
        $$ = option;
    }
    | UNIQUE KEY
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_UNIQ_KEY;
        $$ = option;
    }
    | DEFAULT DefaultValue
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_DEFAULT_VAL;
        option->expr = $2;
        $$ = option;
    }
    | COMMENT STRING_LIT
    {
        ColumnOption* option = new_node(ColumnOption);
        option->type = COLUMN_OPT_COMMENT;
        option->expr = $2;
        $$ = option;
    }
    ;

DefaultValue:
    CURRENT_TIMESTAMP
    {
        FuncExpr* current_timestamp = new_node(FuncExpr);
        current_timestamp->func_type = FT_COMMON;
        current_timestamp->fn_name = "current_timestamp";
        $$ = (ExprNode*)current_timestamp;
    }
    | Expr
    {
        $$ = $1;
    }

PrimaryOpt:
    {}
    | PRIMARY
    ;

DefaultKwdOpt:
    {}
    | DEFAULT
    ;

Constraint:
    ConstraintKeywordOpt ConstraintElem
    {
        if (!$1.empty()) {
            ((Constraint*)$2)->name = $1;
        }
        $$ = $2;
    }
    ;

ConstraintKeywordOpt:
    {
        $$ = nullptr;
    }
    | CONSTRAINT
    {
        $$ = nullptr;
    }
    | CONSTRAINT AllIdent
    {
        $$ = $2;
    }
    ;

ConstraintElem:
    PRIMARY KEY '(' ColumnNameList ')'
    {
        Constraint* item = new_node(Constraint);
        item->type = CONSTRAINT_PRIMARY;
        for (int idx = 0; idx < $4->children.size(); ++idx) {
            item->columns.push_back((ColumnName*)($4->children[idx]), parser->arena);
        }
        $$ = item;
    }
    | FULLTEXT KeyOrIndexOpt IndexName '(' ColumnNameList ')'
    {
        Constraint* item = new_node(Constraint);
        item->type = CONSTRAINT_FULLTEXT;
        item->name = $3;
        for (int idx = 0; idx < $5->children.size(); ++idx) {
            item->columns.push_back((ColumnName*)($5->children[idx]), parser->arena);
        }
        $$ = item;
    }
    | KeyOrIndex IndexName '(' ColumnNameList ')'
    {
        Constraint* item = new_node(Constraint);
        item->type = CONSTRAINT_INDEX;
        item->name = $2;
        for (int idx = 0; idx < $4->children.size(); ++idx) {
            item->columns.push_back((ColumnName*)($4->children[idx]), parser->arena);
        }
        $$ = item;
    }
    | UNIQUE KeyOrIndexOpt IndexName '(' ColumnNameList ')'
    {
        Constraint* item = new_node(Constraint);
        item->type = CONSTRAINT_UNIQ;
        item->name = $3;
        for (int idx = 0; idx < $5->children.size(); ++idx) {
            item->columns.push_back((ColumnName*)($5->children[idx]), parser->arena);
        }
        $$ = item;
    }
    ;

IndexName:
    {
        $$ = nullptr;
    }
    | AllIdent
    {
        $$ = $1;
    }
    ;

/*************************************Type Begin***************************************/
Type:
    NumericType
    {
        $$ = $1;
    }
    |    StringType
    {
        $$ = $1;
    }
    |    DateAndTimeType
    {
        $$ = $1;
    }
    ;

NumericType:
    IntegerType OptFieldLen FieldOpts
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = (MysqlType)$1;
        field_type->total_len = $2;
        Node* list_node = $3;
        for (int idx = 0; idx < list_node->children.size(); ++idx) {
            TypeOption* type_opt = (TypeOption*)(list_node->children[idx]);
            if (type_opt->is_unsigned) {
                field_type->flag |= MYSQL_FIELD_FLAG_UNSIGNED;
            }
            if (type_opt->is_zerofill) {
                field_type->flag |= MYSQL_FIELD_FLAG_ZEROFILL;
            }
        }
        $$ = field_type;
    }
    | BooleanType FieldOpts
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = (MysqlType)$1;
        field_type->total_len = 1;
        Node* list_node = $2;
        for (int idx = 0; idx < list_node->children.size(); ++idx) {
            TypeOption* type_opt = (TypeOption*)(list_node->children[idx]);
            if (type_opt->is_unsigned) {
                field_type->flag |= MYSQL_FIELD_FLAG_UNSIGNED;
            }
            if (type_opt->is_zerofill) {
                field_type->flag |= MYSQL_FIELD_FLAG_ZEROFILL;
            }
        }
        $$ = field_type;
    }
    | FixedPointType FloatOpt FieldOpts
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = (MysqlType)$1;

        FloatOption* float_opt = (FloatOption*)$2;
        field_type->total_len = float_opt->total_len;
        field_type->float_len = float_opt->float_len;

        Node* list_node = $2;
        for (int idx = 0; idx < list_node->children.size(); ++idx) {
            TypeOption* type_opt = (TypeOption*)(list_node->children[idx]);
            if (type_opt->is_unsigned) {
                field_type->flag |= MYSQL_FIELD_FLAG_UNSIGNED;
            }
            if (type_opt->is_zerofill) {
                field_type->flag |= MYSQL_FIELD_FLAG_ZEROFILL;
            }
        }
        $$ = field_type;
    }
    | FloatingPointType FloatOpt FieldOpts
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = (MysqlType)$1;

        FloatOption* float_opt = (FloatOption*)$2;
        field_type->total_len = float_opt->total_len;
        if (field_type->type == MYSQL_TYPE_FLOAT) {
            if (field_type->total_len > MYSQL_FLOAT_PRECISION) {
                field_type->type = MYSQL_TYPE_DOUBLE;
            }
        }
        field_type->float_len = float_opt->float_len;

        Node* list_node = $2;
        for (int idx = 0; idx < list_node->children.size(); ++idx) {
            TypeOption* type_opt = (TypeOption*)(list_node->children[idx]);
            if (type_opt->is_unsigned) {
                field_type->flag |= MYSQL_FIELD_FLAG_UNSIGNED;
            }
            if (type_opt->is_zerofill) {
                field_type->flag |= MYSQL_FIELD_FLAG_ZEROFILL;
            }
        }
        $$ = field_type;
    }
    | BitValueType OptFieldLen
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = (MysqlType)$1;
        
        if ($2 == -1 || $2 == 0) {
            field_type->total_len = 1;
        } else if ($2 > 64) {
            sql_error(&@2, yyscanner, parser, "bit length should between 1 and 64");
        } else {
            field_type->total_len = $2;
        }
        $$ = field_type;
    }
    ;

IntegerType:
    TINYINT
    {
        $$ = MYSQL_TYPE_TINY;
    }
    |    SMALLINT
    {
        $$ = MYSQL_TYPE_SHORT;
    }
    |    MEDIUMINT
    {
        $$ = MYSQL_TYPE_INT24;
    }
    |    INT
    {
        $$ = MYSQL_TYPE_LONG;
    }
    |    INT1
    {
        $$ = MYSQL_TYPE_TINY;
    }
    |     INT2
    {
        $$ = MYSQL_TYPE_SHORT;
    }
    |     INT3
    {
        $$ = MYSQL_TYPE_INT24;
    }
    |    INT4
    {
        $$ = MYSQL_TYPE_LONG;
    }
    |    INT8
    {
        $$ = MYSQL_TYPE_LONGLONG;
    }
    |    INTEGER
    {
        $$ = MYSQL_TYPE_LONG;
    }
    |    BIGINT
    {
        $$ = MYSQL_TYPE_LONGLONG;
    }
    ;

BooleanType:
    BOOL
    {
        $$ = MYSQL_TYPE_TINY;
    }
    |    BOOLEAN
    {
        $$ = MYSQL_TYPE_TINY;
    }
    ;

FixedPointType:
    DECIMAL
    {
        $$ = MYSQL_TYPE_NEWDECIMAL;
    }
    |    NUMERIC
    {
        $$ = MYSQL_TYPE_NEWDECIMAL;
    }
    ;

FloatingPointType:
    FLOAT
    {
        $$ = MYSQL_TYPE_FLOAT;
    }
    | REAL
    {
        $$ = MYSQL_TYPE_DOUBLE;
    }
    | DOUBLE
    {
        $$ = MYSQL_TYPE_DOUBLE;
    }
    | DOUBLE PRECISION
    {
        $$ = MYSQL_TYPE_DOUBLE;
    }
    ;

BitValueType:
    BIT
    {
        $$ = MYSQL_TYPE_BIT;
    }
    ;

StringType:
    NationalOpt CHAR FieldLen OptBinary OptCharset OptCollate
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_STRING;
        field_type->total_len = $3;
        field_type->charset = $5;
        field_type->collate = $6;
        if ($4 == true) {
            field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        }
        $$ = field_type;
    }
    | NationalOpt CHAR OptBinary OptCharset OptCollate
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_STRING;
        field_type->charset = $4;
        field_type->collate = $5;
        if ($3 == true) {
            field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        }
        $$ = field_type;
    }
    | Varchar FieldLen OptBinary OptCharset OptCollate
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_VARCHAR;
        field_type->total_len = $2;
        field_type->charset = $4;
        field_type->collate = $5;
        if ($3 == true) {
            field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        }
        $$ = field_type;
    }
    | BINARY OptFieldLen
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_STRING;
        field_type->total_len = $2;
        field_type->charset.strdup("BINARY", parser->arena);
        field_type->collate.strdup("BINARY", parser->arena);
        field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        $$ = field_type;
    }
    | VARBINARY FieldLen
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_VARCHAR;
        field_type->total_len = $2;
        field_type->charset.strdup("BINARY", parser->arena);
        field_type->collate.strdup("BINARY", parser->arena);
        field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        $$ = field_type;
    }
    | BlobType
    {  
        FieldType* field_type = (FieldType*)$1;
        field_type->charset.strdup("BINARY", parser->arena);
        field_type->collate.strdup("BINARY", parser->arena);
        field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        $$ = field_type;
    }
    | TextType OptBinary OptCharset OptCollate
    {
        FieldType* field_type = (FieldType*)$1;
        field_type->charset = $3;
        field_type->collate = $4;
        if (2 == true) {
            field_type->flag |= MYSQL_FIELD_FLAG_BINARY;
        }
        $$ = field_type;
    }
    | ENUM '(' StringList ')' OptCharset OptCollate
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_ENUM;
        $$ = field_type;
    }
    | SET '(' StringList ')' OptCharset OptCollate
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_SET;
        $$ = field_type;
    }
    | JSON
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_JSON;
        $$ = field_type;
    }
    ;

NationalOpt:
    {}
    |    NATIONAL
    ;

Varchar:
    NATIONAL VARCHAR
    | VARCHAR
    | NVARCHAR
    ;

BlobType:
    TINYBLOB
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_TINY_BLOB;
        $$ = field_type;
    }
    | BLOB OptFieldLen
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_BLOB;
        field_type->total_len = $2;
        $$ = field_type;
    }
    | MEDIUMBLOB
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_MEDIUM_BLOB;
        $$ = field_type;
    }
    | LONGBLOB
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_LONG_BLOB;
        $$ = field_type;
    }
    ;

TextType:
    TINYTEXT
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_TINY_BLOB;
        $$ = field_type;
    }
    | TEXT OptFieldLen
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_BLOB;
        field_type->total_len = $2;
        $$ = field_type;
    }
    | MEDIUMTEXT
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_MEDIUM_BLOB;
        $$ = field_type;
    }
    | LONGTEXT
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_LONG_BLOB;
        $$ = field_type;
    }
    | LONG VARCHAR
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_MEDIUM_BLOB;
        $$ = field_type;
    }
    ;

DateAndTimeType:
    DATE
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_DATE;
        $$ = field_type;
    }
    | DATETIME OptFieldLen
    {
        // TODO: fractional seconds precision
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_DATETIME;
        $$ = field_type;
    }
    | TIMESTAMP OptFieldLen
    {
        // TODO: fractional seconds precision
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_TIMESTAMP;
        $$ = field_type;
    }
    | TIME OptFieldLen
    {
        // TODO: fractional seconds precision
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_TIME;
        $$ = field_type;
    }
    | YEAR OptFieldLen
    {
        FieldType* field_type = new_node(FieldType);
        field_type->type = MYSQL_TYPE_YEAR;
        field_type->total_len = $2;
        if (field_type->total_len != -1 && field_type->total_len != 4) {
            sql_error(&@2, yyscanner, parser, "YEAR length must be set 4.");
            return -1;
        }
        $$ = field_type;
    }
    ;

OptFieldLen:
    /* empty == (-1) == unspecified field length*/
    {
        $$ = -1;
    }
    | FieldLen
    {
        $$ = $1;
    }
    ;

FieldLen:
    '(' INTEGER_LIT ')'
    {
        $$ = ((LiteralExpr*)$2)->_u.int64_val;
    }
    ;

FieldOpt:
    UNSIGNED
    {
        TypeOption* type_opt = new_node(TypeOption);
        type_opt->is_unsigned = true;
        $$ = type_opt;
    }
    | SIGNED
    {
        TypeOption* type_opt = new_node(TypeOption);
        type_opt->is_unsigned = false;
        $$ = type_opt;
    }
    | ZEROFILL
    {
        TypeOption* type_opt = new_node(TypeOption);
        type_opt->is_unsigned = true;
        type_opt->is_zerofill = true;
        $$ = type_opt;
    }
    ;

FieldOpts:
    {
        $$ = new_node(Node);
    }
    |    FieldOpts FieldOpt
    {
        $1->children.push_back($2, parser->arena);
        $$ = $1;
    }
    ;

FloatOpt:
    {
        FloatOption* float_opt = new_node(FloatOption);
        $$ = float_opt;
    }
    |    FieldLen
    {
        FloatOption* float_opt = new_node(FloatOption);
        float_opt->total_len = $1;
        $$ = float_opt;
    }
    |    Precision
    {
        $$ = $1;
    }
    ;

Precision:
    '(' INTEGER_LIT ',' INTEGER_LIT ')'
    {
        FloatOption* float_opt = new_node(FloatOption);
        float_opt->total_len = ((LiteralExpr*)$2)->_u.int64_val;
        float_opt->float_len = ((LiteralExpr*)$4)->_u.int64_val;
        $$ = float_opt;
    }
    ;

OptBinary:
    {
        $$ = false;
    }
    | BINARY
    {
        $$ = true;
    }
    ;

OptCharset:
    {
        $$ = nullptr;
    }
    | CharsetKw StringName
    {
        $$ = $2;
    }
    ;

CharsetKw:
    CHARACTER SET 
    | CHARSET
    ;

OptCollate:
    {
        $$ = nullptr;
    }
    | COLLATE StringName
    {
        $$ = $2;
    }
    ;

StringList:
    STRING_LIT
    {
        Node* list = new_node(Node);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | StringList ',' STRING_LIT
    {
        $1->children.push_back($3, parser->arena
        );
        $$ = $1;
    }
    ;

StringName:
    STRING_LIT
    {
        $$ = ((LiteralExpr*)$1)->_u.str_val;
    }
    | AllIdent
    {
        $$ = $1;
    }
    ;

CreateTableOptionListOpt:
    {
        $$ = new_node(Node);
    }
    | TableOptionList 
    {
        $$ = $1;
    }
    ;

TableOptionList:
    TableOption
    {
        Node* list = new_node(Node);
        list->children.reserve(10, parser->arena);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | TableOptionList TableOption
    {
        $1->children.push_back($2, parser->arena);
        $$ = $1;
    }
    | TableOptionList ','  TableOption
    {
        $1->children.push_back($3, parser->arena);
        $$ = $1;
    }
    ;

TableOption:
    ENGINE EqOpt StringName
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_ENGINE;
        option->str_value = $3;
        $$ = option;
    }
    | DefaultKwdOpt CharsetKw EqOpt StringName
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_CHARSET;
        option->str_value = $4;
        $$ = option;
    }
    | DefaultKwdOpt COLLATE EqOpt StringName
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_COLLATE;
        option->str_value = $4;
        $$ = option;
    }
    | AUTO_INCREMENT EqOpt INTEGER_LIT
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_AUTO_INC;
        option->uint_value = ((LiteralExpr*)$3)->_u.int64_val;
        $$ = option;
    }
    | COMMENT EqOpt STRING_LIT
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_COMMENT;
        option->str_value = ((LiteralExpr*)$3)->_u.str_val;
        $$ = option;
    }
    | AVG_ROW_LENGTH EqOpt INTEGER_LIT
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_AVG_ROW_LENGTH;
        option->uint_value = ((LiteralExpr*)$3)->_u.int64_val;
        $$ = option;
    }
    | KEY_BLOCK_SIZE EqOpt INTEGER_LIT
    {
        TableOption* option = new_node(TableOption);
        option->type = TABLE_OPT_KEY_BLOCK_SIZE;
        option->uint_value = ((LiteralExpr*)$3)->_u.int64_val;
        $$ = option;
    }
    ;

EqOpt:
    {}
    | EQ_OP
    ;

// Drop Table(s) Statement
DropTableStmt:
    DROP TableOrTables IfExists TableNameList RestrictOrCascadeOpt
    {
        DropTableStmt* stmt = new_node(DropTableStmt);
        stmt->if_exist = $3;
        for (int i = 0; i < $4->children.size(); i++) {
            stmt->table_names.push_back((TableName*)$4->children[i], parser->arena);
        }
        $$ = stmt;
    }
    ;

TableOrTables: 
    TABLE | TABLES
    ;

RestrictOrCascadeOpt:
    {}
    | RESTRICT
    | CASCADE
    ;

// Create Database Statement
CreateDatabaseStmt:
    CREATE DATABASE IfNotExists DBName DatabaseOptionListOpt
    {
        CreateDatabaseStmt* stmt = new_node(CreateDatabaseStmt);
        stmt->if_not_exist = $3;
        stmt->db_name = $4;
        for (int idx = 0; idx < $5->children.size(); ++idx) {
            stmt->options.push_back((DatabaseOption*)$5->children[idx], parser->arena);
        }
        $$ = stmt;
    }
    ;

DBName:
    AllIdent {
        $$ = $1;
    }
    ;

DatabaseOption:
    DefaultKwdOpt CharsetKw EqOpt StringName
    {
        DatabaseOption* option = new_node(DatabaseOption);
        option->type = DATABASE_OPT_CHARSET;
        option->str_value = $4;
        $$ = option;
    }
    | DefaultKwdOpt COLLATE EqOpt StringName
    {
        DatabaseOption* option = new_node(DatabaseOption);
        option->type = DATABASE_OPT_COLLATE;
        option->str_value = $4;
        $$ = option;
    }
    ;

DatabaseOptionListOpt:
    {
        $$ = new_node(Node);
    }
    | DatabaseOptionList
    {
        $$ = $1;
    }
    ;

DatabaseOptionList:
    DatabaseOption
    {
        Node* list = new_node(Node);
        list->children.push_back($1, parser->arena);
        $$ = list;
    }
    | DatabaseOptionList DatabaseOption
    {
        Node* list = $1;
        list->children.push_back($2, parser->arena);
        $$ = list;
    }
    ;

DropDatabaseStmt:
    DROP DATABASE IfExists DBName
    {
        DropDatabaseStmt* stmt = new_node(DropDatabaseStmt);
        stmt->if_exist = $3;
        stmt->db_name = $4;
        $$ = stmt;
    }
    ;

WorkOpt:
    {}
    | WORK
    ;

StartTransactionStmt:
    START TRANSACTION
    {
        $$ = new_node(StartTxnStmt);
    }
    | BEGINX WorkOpt
    {
        $$ = new_node(StartTxnStmt);;
    }
    ;

CommitTransactionStmt:
    COMMIT WorkOpt
    {
        $$ = new_node(CommitTxnStmt);
    }
    ;

RollbackTransactionStmt:
    ROLLBACK WorkOpt
    {
        $$ = new_node(RollbackTxnStmt);
    }
    ;

SetStmt:
    SET VarAssignList
    {
        $$ = $2;
    }
    ;

VarAssignList:
    VarAssignItem
    {   
        SetStmt* set = new_node(SetStmt);
        set->var_list.push_back((VarAssign*)$1, parser->arena);
        $$ = set;
    }
    | VarAssignList ',' VarAssignItem
    {
        ((SetStmt*)$1)->var_list.push_back((VarAssign*)$3, parser->arena);
        $$ = $1;
    }
    ;

VarAssignItem:
    VarName EQ_OP Expr
    {
        VarAssign* assign = new_node(VarAssign);
        assign->key = $1;
        assign->value = $3;
        $$ = assign;
    }
    | VarName ASSIGN_OP Expr
    {
        VarAssign* assign = new_node(VarAssign);
        assign->key = $1;
        assign->value = $3;
        $$ = assign;
    }
    | CharsetKw AllIdent
    {
        VarAssign* assign = nullptr;
        if ($2.empty() == false) {
            assign = new_node(VarAssign);
            assign->key.strdup("CHARACTER SET", parser->arena);
            assign->value = LiteralExpr::make_string($2.value, parser->arena);
        }
        $$ = assign;
    }
    ;

VarName:
    AllIdent
    {
        $$ = $1;
    }
    | GLOBAL AllIdent
    {
        String str;
        if ($2.empty() == false) {
            str.strdup("@@global.", parser->arena);
            str.append($2.c_str(), parser->arena);
        }
        $$ = str;
    }
    | SESSION AllIdent
    {
        String str;
        if ($2.empty() == false) {
            str.strdup("@@session.", parser->arena);
            str.append($2.c_str(), parser->arena);
        }
        $$ = str;
    }
    ;

ShowStmt:
    SHOW ShowTargetFilterable ShowLikeOrWhereOpt {
        $$ = nullptr;
    }
    | SHOW CREATE TABLE TableName {
        $$ = nullptr;
    }
    | SHOW CREATE DATABASE DBName {
        $$ = nullptr;
    }
    | SHOW GRANTS {
        // See https://dev.mysql.com/doc/refman/5.7/en/show-grants.html
        $$ = nullptr;
    }
/*
    | SHOW GRANTS FOR Username {
        $$ = nullptr;
    }
*/
    | SHOW MASTER STATUS {
        $$ = nullptr;
    }
    | SHOW OptFull PROCESSLIST {
        $$ = nullptr;
    }
    | SHOW PROFILES {
        $$ = nullptr;
    }
    | SHOW PRIVILEGES {
        $$ = nullptr;
    }
    ;
ShowIndexKwd:
    INDEX
    | INDEXES
    | KEYS
    ;

FromOrIn:
    FROM | IN

ShowTargetFilterable:
    ENGINES {
        $$ = nullptr;
    }
    | DATABASES {
        $$ = nullptr;
    }
    | CharsetKw {
        $$ = nullptr;
    }
    | OptFull TABLES ShowDatabaseNameOpt {
        $$ = nullptr;
    }
    | TABLE STATUS ShowDatabaseNameOpt {
        $$ = nullptr;
    }
    | ShowIndexKwd FromOrIn TableName {
        $$ = nullptr;
    }

    | ShowIndexKwd FromOrIn AllIdent FromOrIn AllIdent {
        $$ = nullptr;
    }

    | OptFull COLUMNS ShowTableAliasOpt ShowDatabaseNameOpt {
        $$ = nullptr;
    }
    | OptFull FIELDS ShowTableAliasOpt ShowDatabaseNameOpt {
        // SHOW FIELDS is a synonym for SHOW COLUMNS
        $$ = nullptr;
    }
    | WARNINGS {
        $$ = nullptr;
    }
    | GlobalScope VARIABLES {
        $$ = nullptr;
    }
    | GlobalScope STATUS {
        $$ = nullptr;
    }
    | COLLATION {
        $$ = nullptr;
    }
    | TRIGGERS ShowDatabaseNameOpt {
        $$ = nullptr;
    }
    | PROCEDURE STATUS {
        $$ = nullptr;
    }
    | FUNCTION STATUS
    {
        $$ = nullptr;
    }
    | EVENTS ShowDatabaseNameOpt
    {
        $$ = nullptr;
    }
    | PLUGINS {
        $$ = nullptr;
    }
    ;
ShowLikeOrWhereOpt: {
        $$ = nullptr;
    }
    | LIKE SimpleExpr {
        $$ = nullptr;
    }
    | WHERE Expr {
        $$ = nullptr;
    }
    ;
GlobalScope:
    {
        $$ = false
    }
    | GLOBAL {
        $$ = true
    }
    | SESSION {
        $$ = false
    }
    ;
OptFull:
    {
        $$ = false
    }
    | FULL {
        $$ = true
    }
    ;
ShowDatabaseNameOpt:
    {
        $$ = nullptr;
    }
    | FromOrIn DBName {
        $$ = nullptr;
    }
    ;
ShowTableAliasOpt:
    FromOrIn TableName {
        $$ = nullptr
    }
    ;

%%
int sql_error(YYLTYPE* yylloc, yyscan_t yyscanner, SqlParser *parser, const char *s) {    
    parser->error = parser::SYNTAX_ERROR;
    //std::cout << sql_get_lineno(yyscanner) << ":" << sql_get_column(yyscanner) << std::endl;
    std::ostringstream os;
    os << s << ", in [" << yylloc->last_line;
    os << ":" << yylloc->first_column;
    os << "-" << yylloc->last_column;
    os << "] key:" << sql_get_text(yyscanner);
    parser->syntax_err_str = os.str();
    return 1;
    //printf("sql_error");
}

/* vim: set ts=4 sw=4 sts=4 tw=100 */