
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton implementation for Bison LALR(1) parsers in C++
   
      Copyright (C) 2002, 2003, 2004, 2005, 2006, 2007, 2008 Free Software
   Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* First part of user declarations.  */

/* Line 311 of lalr1.cc  */
#line 25 "json_parser.yy"

  #include "parser_p.h"
  #include "json_scanner.h"
  #include "qjson_debug.h"

  #include <QtCore/QByteArray>
  #include <QtCore/QMap>
  #include <QtCore/QString>
  #include <QtCore/QVariant>

  class JSonScanner;

  namespace QJson {
    class Parser;
  }

  #define YYERROR_VERBOSE 1


/* Line 311 of lalr1.cc  */
#line 61 "json_parser.cc"


#include "json_parser.hh"

/* User implementation prologue.  */


/* Line 317 of lalr1.cc  */
#line 70 "json_parser.cc"

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* FIXME: INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#define YYUSE(e) ((void) (e))

/* Enable debugging if requested.  */
#if YYDEBUG

/* A pseudo ostream that takes yydebug_ into account.  */
# define YYCDEBUG if (yydebug_) (*yycdebug_)

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)	\
do {							\
  if (yydebug_)						\
    {							\
      *yycdebug_ << Title << ' ';			\
      yy_symbol_print_ ((Type), (Value), (Location));	\
      *yycdebug_ << std::endl;				\
    }							\
} while (false)

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug_)				\
    yy_reduce_print_ (Rule);		\
} while (false)

# define YY_STACK_PRINT()		\
do {					\
  if (yydebug_)				\
    yystack_print_ ();			\
} while (false)

#else /* !YYDEBUG */

# define YYCDEBUG if (false) std::cerr
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_REDUCE_PRINT(Rule)
# define YY_STACK_PRINT()

#endif /* !YYDEBUG */

#define yyerrok		(yyerrstatus_ = 0)
#define yyclearin	(yychar = yyempty_)

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab
#define YYRECOVERING()  (!!yyerrstatus_)


/* Line 380 of lalr1.cc  */
#line 1 "[Bison:b4_percent_define_default]"

namespace yy {

/* Line 380 of lalr1.cc  */
#line 139 "json_parser.cc"
#if YYERROR_VERBOSE

  /* Return YYSTR after stripping away unnecessary quotes and
     backslashes, so that it's suitable for yyerror.  The heuristic is
     that double-quoting is unnecessary unless the string contains an
     apostrophe, a comma, or backslash (other than backslash-backslash).
     YYSTR is taken from yytname.  */
  std::string
  json_parser::yytnamerr_ (const char *yystr)
  {
    if (*yystr == '"')
      {
        std::string yyr = "";
        char const *yyp = yystr;

        for (;;)
          switch (*++yyp)
            {
            case '\'':
            case ',':
              goto do_not_strip_quotes;

            case '\\':
              if (*++yyp != '\\')
                goto do_not_strip_quotes;
              /* Fall through.  */
            default:
              yyr += *yyp;
              break;

            case '"':
              return yyr;
            }
      do_not_strip_quotes: ;
      }

    return yystr;
  }

#endif

  /// Build a parser object.
  json_parser::json_parser (QJson::ParserPrivate* driver_yyarg)
    :
#if YYDEBUG
      yydebug_ (false),
      yycdebug_ (&std::cerr),
#endif
      driver (driver_yyarg)
  {
  }

  json_parser::~json_parser ()
  {
  }

#if YYDEBUG
  /*--------------------------------.
  | Print this symbol on YYOUTPUT.  |
  `--------------------------------*/

  inline void
  json_parser::yy_symbol_value_print_ (int yytype,
			   const semantic_type* yyvaluep, const location_type* yylocationp)
  {
    YYUSE (yylocationp);
    YYUSE (yyvaluep);
    switch (yytype)
      {
         default:
	  break;
      }
  }


  void
  json_parser::yy_symbol_print_ (int yytype,
			   const semantic_type* yyvaluep, const location_type* yylocationp)
  {
    *yycdebug_ << (yytype < yyntokens_ ? "token" : "nterm")
	       << ' ' << yytname_[yytype] << " ("
	       << *yylocationp << ": ";
    yy_symbol_value_print_ (yytype, yyvaluep, yylocationp);
    *yycdebug_ << ')';
  }
#endif

  void
  json_parser::yydestruct_ (const char* yymsg,
			   int yytype, semantic_type* yyvaluep, location_type* yylocationp)
  {
    YYUSE (yylocationp);
    YYUSE (yymsg);
    YYUSE (yyvaluep);

    YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

    switch (yytype)
      {
  
	default:
	  break;
      }
  }

  void
  json_parser::yypop_ (unsigned int n)
  {
    yystate_stack_.pop (n);
    yysemantic_stack_.pop (n);
    yylocation_stack_.pop (n);
  }

#if YYDEBUG
  std::ostream&
  json_parser::debug_stream () const
  {
    return *yycdebug_;
  }

  void
  json_parser::set_debug_stream (std::ostream& o)
  {
    yycdebug_ = &o;
  }


  json_parser::debug_level_type
  json_parser::debug_level () const
  {
    return yydebug_;
  }

  void
  json_parser::set_debug_level (debug_level_type l)
  {
    yydebug_ = l;
  }
#endif

  int
  json_parser::parse ()
  {
    /// Lookahead and lookahead in internal form.
    int yychar = yyempty_;
    int yytoken = 0;

    /* State.  */
    int yyn;
    int yylen = 0;
    int yystate = 0;

    /* Error handling.  */
    int yynerrs_ = 0;
    int yyerrstatus_ = 0;

    /// Semantic value of the lookahead.
    semantic_type yylval;
    /// Location of the lookahead.
    location_type yylloc;
    /// The locations where the error started and ended.
    location_type yyerror_range[2];

    /// $$.
    semantic_type yyval;
    /// @$.
    location_type yyloc;

    int yyresult;

    YYCDEBUG << "Starting parse" << std::endl;


    /* Initialize the stacks.  The initial state will be pushed in
       yynewstate, since the latter expects the semantical and the
       location values to have been already stored, initialize these
       stacks with a primary value.  */
    yystate_stack_ = state_stack_type (0);
    yysemantic_stack_ = semantic_stack_type (0);
    yylocation_stack_ = location_stack_type (0);
    yysemantic_stack_.push (yylval);
    yylocation_stack_.push (yylloc);

    /* New state.  */
  yynewstate:
    yystate_stack_.push (yystate);
    YYCDEBUG << "Entering state " << yystate << std::endl;

    /* Accept?  */
    if (yystate == yyfinal_)
      goto yyacceptlab;

    goto yybackup;

    /* Backup.  */
  yybackup:

    /* Try to take a decision without lookahead.  */
    yyn = yypact_[yystate];
    if (yyn == yypact_ninf_)
      goto yydefault;

    /* Read a lookahead token.  */
    if (yychar == yyempty_)
      {
	YYCDEBUG << "Reading a token: ";
	yychar = yylex (&yylval, &yylloc, driver);
      }


    /* Convert token to internal form.  */
    if (yychar <= yyeof_)
      {
	yychar = yytoken = yyeof_;
	YYCDEBUG << "Now at end of input." << std::endl;
      }
    else
      {
	yytoken = yytranslate_ (yychar);
	YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
      }

    /* If the proper action on seeing token YYTOKEN is to reduce or to
       detect an error, take that action.  */
    yyn += yytoken;
    if (yyn < 0 || yylast_ < yyn || yycheck_[yyn] != yytoken)
      goto yydefault;

    /* Reduce or error.  */
    yyn = yytable_[yyn];
    if (yyn <= 0)
      {
	if (yyn == 0 || yyn == yytable_ninf_)
	goto yyerrlab;
	yyn = -yyn;
	goto yyreduce;
      }

    /* Shift the lookahead token.  */
    YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

    /* Discard the token being shifted.  */
    yychar = yyempty_;

    yysemantic_stack_.push (yylval);
    yylocation_stack_.push (yylloc);

    /* Count tokens shifted since error; after three, turn off error
       status.  */
    if (yyerrstatus_)
      --yyerrstatus_;

    yystate = yyn;
    goto yynewstate;

  /*-----------------------------------------------------------.
  | yydefault -- do the default action for the current state.  |
  `-----------------------------------------------------------*/
  yydefault:
    yyn = yydefact_[yystate];
    if (yyn == 0)
      goto yyerrlab;
    goto yyreduce;

  /*-----------------------------.
  | yyreduce -- Do a reduction.  |
  `-----------------------------*/
  yyreduce:
    yylen = yyr2_[yyn];
    /* If YYLEN is nonzero, implement the default value of the action:
       `$$ = $1'.  Otherwise, use the top of the stack.

       Otherwise, the following line sets YYVAL to garbage.
       This behavior is undocumented and Bison
       users should not rely upon it.  */
    if (yylen)
      yyval = yysemantic_stack_[yylen - 1];
    else
      yyval = yysemantic_stack_[0];

    {
      slice<location_type, location_stack_type> slice (yylocation_stack_, yylen);
      YYLLOC_DEFAULT (yyloc, slice, yylen);
    }
    YY_REDUCE_PRINT (yyn);
    switch (yyn)
      {
	  case 2:

/* Line 678 of lalr1.cc  */
#line 80 "json_parser.yy"
    {
              driver->m_result = (yysemantic_stack_[(1) - (1)]);
              qjsonDebug() << "json_parser - parsing finished";
            }
    break;

  case 3:

/* Line 678 of lalr1.cc  */
#line 85 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(1) - (1)]); }
    break;

  case 4:

/* Line 678 of lalr1.cc  */
#line 87 "json_parser.yy"
    {
            qCritical()<< "json_parser - syntax error found, "
                    << "forcing abort";
            YYABORT;
          }
    break;

  case 6:

/* Line 678 of lalr1.cc  */
#line 94 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(3) - (2)]); }
    break;

  case 7:

/* Line 678 of lalr1.cc  */
#line 96 "json_parser.yy"
    { (yyval) = QVariant (QVariantMap()); }
    break;

  case 8:

/* Line 678 of lalr1.cc  */
#line 97 "json_parser.yy"
    {
            QVariantMap members = (yysemantic_stack_[(2) - (2)]).toMap();
            (yysemantic_stack_[(2) - (2)]) = QVariant(); // Allow reuse of map
            (yyval) = QVariant(members.unite ((yysemantic_stack_[(2) - (1)]).toMap()));
          }
    break;

  case 9:

/* Line 678 of lalr1.cc  */
#line 103 "json_parser.yy"
    { (yyval) = QVariant (QVariantMap()); }
    break;

  case 10:

/* Line 678 of lalr1.cc  */
#line 104 "json_parser.yy"
    {
          QVariantMap members = (yysemantic_stack_[(3) - (3)]).toMap();
          (yysemantic_stack_[(3) - (3)]) = QVariant(); // Allow reuse of map
          (yyval) = QVariant(members.unite ((yysemantic_stack_[(3) - (2)]).toMap()));
          }
    break;

  case 11:

/* Line 678 of lalr1.cc  */
#line 110 "json_parser.yy"
    {
            QVariantMap pair;
            pair.insert ((yysemantic_stack_[(3) - (1)]).toString(), QVariant((yysemantic_stack_[(3) - (3)])));
            (yyval) = QVariant (pair);
          }
    break;

  case 12:

/* Line 678 of lalr1.cc  */
#line 116 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(3) - (2)]); }
    break;

  case 13:

/* Line 678 of lalr1.cc  */
#line 118 "json_parser.yy"
    { (yyval) = QVariant (QVariantList()); }
    break;

  case 14:

/* Line 678 of lalr1.cc  */
#line 119 "json_parser.yy"
    {
          QVariantList members = (yysemantic_stack_[(2) - (2)]).toList();
          (yysemantic_stack_[(2) - (2)]) = QVariant(); // Allow reuse of list
          members.prepend ((yysemantic_stack_[(2) - (1)]));
          (yyval) = QVariant(members);
        }
    break;

  case 15:

/* Line 678 of lalr1.cc  */
#line 126 "json_parser.yy"
    { (yyval) = QVariant (QVariantList()); }
    break;

  case 16:

/* Line 678 of lalr1.cc  */
#line 127 "json_parser.yy"
    {
            QVariantList members = (yysemantic_stack_[(3) - (3)]).toList();
            (yysemantic_stack_[(3) - (3)]) = QVariant(); // Allow reuse of list
            members.prepend ((yysemantic_stack_[(3) - (2)]));
            (yyval) = QVariant(members);
          }
    break;

  case 17:

/* Line 678 of lalr1.cc  */
#line 134 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(1) - (1)]); }
    break;

  case 18:

/* Line 678 of lalr1.cc  */
#line 135 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(1) - (1)]); }
    break;

  case 19:

/* Line 678 of lalr1.cc  */
#line 136 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(1) - (1)]); }
    break;

  case 20:

/* Line 678 of lalr1.cc  */
#line 137 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(1) - (1)]); }
    break;

  case 21:

/* Line 678 of lalr1.cc  */
#line 138 "json_parser.yy"
    { (yyval) = QVariant (true); }
    break;

  case 22:

/* Line 678 of lalr1.cc  */
#line 139 "json_parser.yy"
    { (yyval) = QVariant (false); }
    break;

  case 23:

/* Line 678 of lalr1.cc  */
#line 140 "json_parser.yy"
    {
          QVariant null_variant;
          (yyval) = null_variant;
        }
    break;

  case 24:

/* Line 678 of lalr1.cc  */
#line 145 "json_parser.yy"
    {
            if ((yysemantic_stack_[(1) - (1)]).toByteArray().startsWith('-')) {
              (yyval) = QVariant::fromValue<qlonglong>((yysemantic_stack_[(1) - (1)]).toLongLong());
            }
            else {
              (yyval) = QVariant::fromValue<qulonglong>((yysemantic_stack_[(1) - (1)]).toULongLong());
            }
          }
    break;

  case 25:

/* Line 678 of lalr1.cc  */
#line 153 "json_parser.yy"
    {
            const QByteArray value = (yysemantic_stack_[(2) - (1)]).toByteArray() + (yysemantic_stack_[(2) - (2)]).toByteArray();
            (yyval) = QVariant::fromValue<double>(value.toDouble());
          }
    break;

  case 26:

/* Line 678 of lalr1.cc  */
#line 157 "json_parser.yy"
    {
            const QByteArray value = (yysemantic_stack_[(2) - (1)]).toByteArray() + (yysemantic_stack_[(2) - (2)]).toByteArray();
            (yyval) = QVariant::fromValue<double>(value.toDouble());
        }
    break;

  case 27:

/* Line 678 of lalr1.cc  */
#line 161 "json_parser.yy"
    {
            const QByteArray value = (yysemantic_stack_[(3) - (1)]).toByteArray() + (yysemantic_stack_[(3) - (2)]).toByteArray() + (yysemantic_stack_[(3) - (3)]).toByteArray();
            (yyval) = QVariant::fromValue<double>(value.toDouble());
          }
    break;

  case 28:

/* Line 678 of lalr1.cc  */
#line 166 "json_parser.yy"
    { (yyval) = QVariant ((yysemantic_stack_[(2) - (1)]).toByteArray() + (yysemantic_stack_[(2) - (2)]).toByteArray()); }
    break;

  case 29:

/* Line 678 of lalr1.cc  */
#line 167 "json_parser.yy"
    { (yyval) = QVariant (QByteArray("-") + (yysemantic_stack_[(3) - (2)]).toByteArray() + (yysemantic_stack_[(3) - (3)]).toByteArray()); }
    break;

  case 30:

/* Line 678 of lalr1.cc  */
#line 169 "json_parser.yy"
    { (yyval) = QVariant (QByteArray("")); }
    break;

  case 31:

/* Line 678 of lalr1.cc  */
#line 170 "json_parser.yy"
    {
          (yyval) = QVariant((yysemantic_stack_[(2) - (1)]).toByteArray() + (yysemantic_stack_[(2) - (2)]).toByteArray());
        }
    break;

  case 32:

/* Line 678 of lalr1.cc  */
#line 174 "json_parser.yy"
    {
          (yyval) = QVariant(QByteArray(".") + (yysemantic_stack_[(2) - (2)]).toByteArray());
        }
    break;

  case 33:

/* Line 678 of lalr1.cc  */
#line 178 "json_parser.yy"
    { (yyval) = QVariant((yysemantic_stack_[(2) - (1)]).toByteArray() + (yysemantic_stack_[(2) - (2)]).toByteArray()); }
    break;

  case 34:

/* Line 678 of lalr1.cc  */
#line 180 "json_parser.yy"
    { (yyval) = (yysemantic_stack_[(3) - (2)]); }
    break;

  case 35:

/* Line 678 of lalr1.cc  */
#line 182 "json_parser.yy"
    { (yyval) = QVariant (QString(QLatin1String(""))); }
    break;

  case 36:

/* Line 678 of lalr1.cc  */
#line 183 "json_parser.yy"
    {
                (yyval) = (yysemantic_stack_[(1) - (1)]);
              }
    break;



/* Line 678 of lalr1.cc  */
#line 722 "json_parser.cc"
	default:
          break;
      }
    YY_SYMBOL_PRINT ("-> $$ =", yyr1_[yyn], &yyval, &yyloc);

    yypop_ (yylen);
    yylen = 0;
    YY_STACK_PRINT ();

    yysemantic_stack_.push (yyval);
    yylocation_stack_.push (yyloc);

    /* Shift the result of the reduction.  */
    yyn = yyr1_[yyn];
    yystate = yypgoto_[yyn - yyntokens_] + yystate_stack_[0];
    if (0 <= yystate && yystate <= yylast_
	&& yycheck_[yystate] == yystate_stack_[0])
      yystate = yytable_[yystate];
    else
      yystate = yydefgoto_[yyn - yyntokens_];
    goto yynewstate;

  /*------------------------------------.
  | yyerrlab -- here on detecting error |
  `------------------------------------*/
  yyerrlab:
    /* If not already recovering from an error, report this error.  */
    if (!yyerrstatus_)
      {
	++yynerrs_;
	error (yylloc, yysyntax_error_ (yystate, yytoken));
      }

    yyerror_range[0] = yylloc;
    if (yyerrstatus_ == 3)
      {
	/* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

	if (yychar <= yyeof_)
	  {
	  /* Return failure if at end of input.  */
	  if (yychar == yyeof_)
	    YYABORT;
	  }
	else
	  {
	    yydestruct_ ("Error: discarding", yytoken, &yylval, &yylloc);
	    yychar = yyempty_;
	  }
      }

    /* Else will try to reuse lookahead token after shifting the error
       token.  */
    goto yyerrlab1;


  /*---------------------------------------------------.
  | yyerrorlab -- error raised explicitly by YYERROR.  |
  `---------------------------------------------------*/
  yyerrorlab:

    /* Pacify compilers like GCC when the user code never invokes
       YYERROR and the label yyerrorlab therefore never appears in user
       code.  */
    if (false)
      goto yyerrorlab;

    yyerror_range[0] = yylocation_stack_[yylen - 1];
    /* Do not reclaim the symbols of the rule which action triggered
       this YYERROR.  */
    yypop_ (yylen);
    yylen = 0;
    yystate = yystate_stack_[0];
    goto yyerrlab1;

  /*-------------------------------------------------------------.
  | yyerrlab1 -- common code for both syntax error and YYERROR.  |
  `-------------------------------------------------------------*/
  yyerrlab1:
    yyerrstatus_ = 3;	/* Each real token shifted decrements this.  */

    for (;;)
      {
	yyn = yypact_[yystate];
	if (yyn != yypact_ninf_)
	{
	  yyn += yyterror_;
	  if (0 <= yyn && yyn <= yylast_ && yycheck_[yyn] == yyterror_)
	    {
	      yyn = yytable_[yyn];
	      if (0 < yyn)
		break;
	    }
	}

	/* Pop the current state because it cannot handle the error token.  */
	if (yystate_stack_.height () == 1)
	YYABORT;

	yyerror_range[0] = yylocation_stack_[0];
	yydestruct_ ("Error: popping",
		     yystos_[yystate],
		     &yysemantic_stack_[0], &yylocation_stack_[0]);
	yypop_ ();
	yystate = yystate_stack_[0];
	YY_STACK_PRINT ();
      }

    yyerror_range[1] = yylloc;
    // Using YYLLOC is tempting, but would change the location of
    // the lookahead.  YYLOC is available though.
    YYLLOC_DEFAULT (yyloc, (yyerror_range - 1), 2);
    yysemantic_stack_.push (yylval);
    yylocation_stack_.push (yyloc);

    /* Shift the error token.  */
    YY_SYMBOL_PRINT ("Shifting", yystos_[yyn],
		     &yysemantic_stack_[0], &yylocation_stack_[0]);

    yystate = yyn;
    goto yynewstate;

    /* Accept.  */
  yyacceptlab:
    yyresult = 0;
    goto yyreturn;

    /* Abort.  */
  yyabortlab:
    yyresult = 1;
    goto yyreturn;

  yyreturn:
    if (yychar != yyempty_)
      yydestruct_ ("Cleanup: discarding lookahead", yytoken, &yylval, &yylloc);

    /* Do not reclaim the symbols of the rule which action triggered
       this YYABORT or YYACCEPT.  */
    yypop_ (yylen);
    while (yystate_stack_.height () != 1)
      {
	yydestruct_ ("Cleanup: popping",
		   yystos_[yystate_stack_[0]],
		   &yysemantic_stack_[0],
		   &yylocation_stack_[0]);
	yypop_ ();
      }

    return yyresult;
  }

  // Generate an error message.
  std::string
  json_parser::yysyntax_error_ (int yystate, int tok)
  {
    std::string res;
    YYUSE (yystate);
#if YYERROR_VERBOSE
    int yyn = yypact_[yystate];
    if (yypact_ninf_ < yyn && yyn <= yylast_)
      {
	/* Start YYX at -YYN if negative to avoid negative indexes in
	   YYCHECK.  */
	int yyxbegin = yyn < 0 ? -yyn : 0;

	/* Stay within bounds of both yycheck and yytname.  */
	int yychecklim = yylast_ - yyn + 1;
	int yyxend = yychecklim < yyntokens_ ? yychecklim : yyntokens_;
	int count = 0;
	for (int x = yyxbegin; x < yyxend; ++x)
	  if (yycheck_[x + yyn] == x && x != yyterror_)
	    ++count;

	// FIXME: This method of building the message is not compatible
	// with internationalization.  It should work like yacc.c does it.
	// That is, first build a string that looks like this:
	// "syntax error, unexpected %s or %s or %s"
	// Then, invoke YY_ on this string.
	// Finally, use the string as a format to output
	// yytname_[tok], etc.
	// Until this gets fixed, this message appears in English only.
	res = "syntax error, unexpected ";
	res += yytnamerr_ (yytname_[tok]);
	if (count < 5)
	  {
	    count = 0;
	    for (int x = yyxbegin; x < yyxend; ++x)
	      if (yycheck_[x + yyn] == x && x != yyterror_)
		{
		  res += (!count++) ? ", expecting " : " or ";
		  res += yytnamerr_ (yytname_[x]);
		}
	  }
      }
    else
#endif
      res = YY_("syntax error");
    return res;
  }


  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
  const signed char json_parser::yypact_ninf_ = -19;
  const signed char
  json_parser::yypact_[] =
  {
         3,   -19,   -19,   -15,    27,    -2,     0,   -19,   -19,   -19,
      -8,    13,   -19,   -19,   -19,   -19,   -19,    -5,   -19,    11,
      12,    16,    18,    17,     0,     0,   -19,   -19,     9,   -19,
       0,     0,    19,   -19,   -19,   -15,   -19,    27,   -19,    27,
     -19,   -19,   -19,   -19,   -19,   -19,   -19,    12,   -19,    17,
     -19,   -19
  };

  /* YYDEFACT[S] -- default rule to reduce with in state S when YYTABLE
     doesn't specify something else to do.  Zero means the default is an
     error.  */
  const unsigned char
  json_parser::yydefact_[] =
  {
         0,     5,     4,     7,    13,     0,    30,    21,    22,    23,
      35,     0,     2,    19,    20,     3,    18,    24,    17,     0,
       9,     0,     0,    15,    30,    30,    28,    36,     0,     1,
      30,    30,    25,    26,     6,     0,     8,     0,    12,     0,
      14,    29,    31,    34,    32,    33,    27,     9,    11,    15,
      10,    16
  };

  /* YYPGOTO[NTERM-NUM].  */
  const signed char
  json_parser::yypgoto_[] =
  {
       -19,   -19,   -19,   -19,   -19,   -18,     2,   -19,   -19,   -10,
      -4,   -19,   -19,    -3,   -19,    14,    -1,   -19
  };

  /* YYDEFGOTO[NTERM-NUM].  */
  const signed char
  json_parser::yydefgoto_[] =
  {
        -1,    11,    12,    13,    19,    36,    20,    14,    22,    40,
      15,    16,    17,    26,    32,    33,    18,    28
  };

  /* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule which
     number is the opposite.  If zero, do what YYDEFACT says.  */
  const signed char json_parser::yytable_ninf_ = -1;
  const unsigned char
  json_parser::yytable_[] =
  {
        23,    10,    21,     1,     2,    30,     3,    31,     4,    24,
      27,    25,     5,    29,     6,    34,     7,     8,     9,    10,
      35,    41,    42,    37,    38,    39,    43,    44,    45,    50,
       3,    31,     4,    48,    21,    49,     5,    47,     6,    51,
       7,     8,     9,    10,     0,     0,    46
  };

  /* YYCHECK.  */
  const signed char
  json_parser::yycheck_[] =
  {
         4,    16,     3,     0,     1,    10,     3,    12,     5,    11,
      18,    11,     9,     0,    11,     4,    13,    14,    15,    16,
       8,    24,    25,     7,     6,     8,    17,    30,    31,    47,
       3,    12,     5,    37,    35,    39,     9,    35,    11,    49,
      13,    14,    15,    16,    -1,    -1,    32
  };

  /* STOS_[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
  const unsigned char
  json_parser::yystos_[] =
  {
         0,     0,     1,     3,     5,     9,    11,    13,    14,    15,
      16,    20,    21,    22,    26,    29,    30,    31,    35,    23,
      25,    35,    27,    29,    11,    11,    32,    18,    36,     0,
      10,    12,    33,    34,     4,     8,    24,     7,     6,     8,
      28,    32,    32,    17,    32,    32,    34,    25,    29,    29,
      24,    28
  };

#if YYDEBUG
  /* TOKEN_NUMBER_[YYLEX-NUM] -- Internal symbol number corresponding
     to YYLEX-NUM.  */
  const unsigned short int
  json_parser::yytoken_number_[] =
  {
         0,   256,   257,     1,     2,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    15,    16
  };
#endif

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
  const unsigned char
  json_parser::yyr1_[] =
  {
         0,    19,    20,    21,    21,    21,    22,    23,    23,    24,
      24,    25,    26,    27,    27,    28,    28,    29,    29,    29,
      29,    29,    29,    29,    30,    30,    30,    30,    31,    31,
      32,    32,    33,    34,    35,    36,    36
  };

  /* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
  const unsigned char
  json_parser::yyr2_[] =
  {
         0,     2,     1,     1,     1,     1,     3,     0,     2,     0,
       3,     3,     3,     0,     2,     0,     3,     1,     1,     1,
       1,     1,     1,     1,     1,     2,     2,     3,     2,     3,
       0,     2,     2,     2,     3,     0,     1
  };

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
  /* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
     First, the terminals, then, starting at \a yyntokens_, nonterminals.  */
  const char*
  const json_parser::yytname_[] =
  {
    "\"end of file\"", "error", "$undefined", "\"{\"", "\"}\"", "\"[\"",
  "\"]\"", "\":\"", "\",\"", "\"-\"", "\".\"", "\"digit\"",
  "\"exponential\"", "\"true\"", "\"false\"", "\"null\"",
  "\"open quotation mark\"", "\"close quotation mark\"", "\"string\"",
  "$accept", "start", "data", "object", "members", "r_members", "pair",
  "array", "values", "r_values", "value", "number", "int", "digits",
  "fract", "exp", "string", "string_arg", 0
  };
#endif

#if YYDEBUG
  /* YYRHS -- A `-1'-separated list of the rules' RHS.  */
  const json_parser::rhs_number_type
  json_parser::yyrhs_[] =
  {
        20,     0,    -1,    21,    -1,    29,    -1,     1,    -1,     0,
      -1,     3,    23,     4,    -1,    -1,    25,    24,    -1,    -1,
       8,    25,    24,    -1,    35,     7,    29,    -1,     5,    27,
       6,    -1,    -1,    29,    28,    -1,    -1,     8,    29,    28,
      -1,    35,    -1,    30,    -1,    22,    -1,    26,    -1,    13,
      -1,    14,    -1,    15,    -1,    31,    -1,    31,    33,    -1,
      31,    34,    -1,    31,    33,    34,    -1,    11,    32,    -1,
       9,    11,    32,    -1,    -1,    11,    32,    -1,    10,    32,
      -1,    12,    32,    -1,    16,    36,    17,    -1,    -1,    18,
      -1
  };

  /* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
     YYRHS.  */
  const unsigned char
  json_parser::yyprhs_[] =
  {
         0,     0,     3,     5,     7,     9,    11,    15,    16,    19,
      20,    24,    28,    32,    33,    36,    37,    41,    43,    45,
      47,    49,    51,    53,    55,    57,    60,    63,    67,    70,
      74,    75,    78,    81,    84,    88,    89
  };

  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
  const unsigned char
  json_parser::yyrline_[] =
  {
         0,    80,    80,    85,    86,    92,    94,    96,    97,   103,
     104,   110,   116,   118,   119,   126,   127,   134,   135,   136,
     137,   138,   139,   140,   145,   153,   157,   161,   166,   167,
     169,   170,   174,   178,   180,   182,   183
  };

  // Print the state stack on the debug stream.
  void
  json_parser::yystack_print_ ()
  {
    *yycdebug_ << "Stack now";
    for (state_stack_type::const_iterator i = yystate_stack_.begin ();
	 i != yystate_stack_.end (); ++i)
      *yycdebug_ << ' ' << *i;
    *yycdebug_ << std::endl;
  }

  // Report on the debug stream that the rule \a yyrule is going to be reduced.
  void
  json_parser::yy_reduce_print_ (int yyrule)
  {
    unsigned int yylno = yyrline_[yyrule];
    int yynrhs = yyr2_[yyrule];
    /* Print the symbols being reduced, and their result.  */
    *yycdebug_ << "Reducing stack by rule " << yyrule - 1
	       << " (line " << yylno << "):" << std::endl;
    /* The symbols being reduced.  */
    for (int yyi = 0; yyi < yynrhs; yyi++)
      YY_SYMBOL_PRINT ("   $" << yyi + 1 << " =",
		       yyrhs_[yyprhs_[yyrule] + yyi],
		       &(yysemantic_stack_[(yynrhs) - (yyi + 1)]),
		       &(yylocation_stack_[(yynrhs) - (yyi + 1)]));
  }
#endif // YYDEBUG

  /* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
  json_parser::token_number_type
  json_parser::yytranslate_ (int t)
  {
    static
    const token_number_type
    translate_table[] =
    {
           0,     3,     4,     5,     6,     7,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2
    };
    if ((unsigned int) t <= yyuser_token_number_max_)
      return translate_table[t];
    else
      return yyundef_token_;
  }

  const int json_parser::yyeof_ = 0;
  const int json_parser::yylast_ = 46;
  const int json_parser::yynnts_ = 18;
  const int json_parser::yyempty_ = -2;
  const int json_parser::yyfinal_ = 29;
  const int json_parser::yyterror_ = 1;
  const int json_parser::yyerrcode_ = 256;
  const int json_parser::yyntokens_ = 19;

  const unsigned int json_parser::yyuser_token_number_max_ = 257;
  const json_parser::token_number_type json_parser::yyundef_token_ = 2;


/* Line 1054 of lalr1.cc  */
#line 1 "[Bison:b4_percent_define_default]"

} // yy

/* Line 1054 of lalr1.cc  */
#line 1181 "json_parser.cc"


/* Line 1056 of lalr1.cc  */
#line 187 "json_parser.yy"


int yy::yylex(YYSTYPE *yylval, yy::location *yylloc, QJson::ParserPrivate* driver)
{
  JSonScanner* scanner = driver->m_scanner;
  yylval->clear();
  int ret = scanner->yylex(yylval, yylloc);

  qjsonDebug() << "json_parser::yylex - calling scanner yylval==|"
           << yylval->toByteArray() << "|, ret==|" << QString::number(ret) << "|";
  
  return ret;
}

void yy::json_parser::error (const yy::location& yyloc,
                                 const std::string& error)
{
  /*qjsonDebug() << yyloc.begin.line;
  qjsonDebug() << yyloc.begin.column;
  qjsonDebug() << yyloc.end.line;
  qjsonDebug() << yyloc.end.column;*/
  qjsonDebug() << "json_parser::error [line" << yyloc.end.line << "] -" << error.c_str() ;
  driver->setError(QString::fromLatin1(error.c_str()), yyloc.end.line);
}

