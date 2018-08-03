/* $Id:$ */
filename _bcin TEMP;
filename _bcout "ndctest.zip";
run;

proc http method = "get"
    url = "http://www.accessdata.fda.gov/cder/ndctext.zip"
    out = _bcin
    ;
run;

%if "&SYS_PROCHTTP_STATUS_CODE." = "200" %then %do;
    %binaryFileCopy();
    %put MHN-NOTE: _bcrc=&_bcrc;
    %let NDC_FOUND = Y;
    %end;

filename _bcin clear;
filename _bcout clear;
run;

%if "&NDC_FOUND." = "Y" %then %do;

filename ndc zip 'ndctext.zip';
run;
libname FDA "sasdata";
run;

data FDA.product( drop = _: SEQNO SubstanceName Active_Numerator_Strength Active_Ingred_Unit Pharm_Classes )
    FDA.substance( keep = productID productNDC SEQNO SubstanceName Active_Numerator_Strength Active_Ingred_Unit Pharm_Classes )
    ;
    attrib PRODUCTID                        length = $ 50   format=$char50.   informat=$char50.   label = 'Product ID';
    attrib PRODUCTNDC                       length = $ 15   format=$char15.   informat=$char15.   label = 'Product NDC';
    attrib PRODUCTTYPENAME                  length = $ 30   format=$char30.   informat=$char30.   label = 'SPL Document Type';
    attrib PROPRIETARYNAME                  length = $ 240  format=$char240.  informat=$char240.  label = 'Trade Name';
    attrib PROPRIETARYNAMESUFFIX            length = $ 140  format=$char140.  informat=$char140.  label = 'Proprietary Name Suffix';
    attrib NONPROPRIETARYNAME               length = $ 600  format=$char600.  informat=$char600.  label = 'Generic Name (Active Ingredients)';
    attrib DOSAGEFORMNAME                   length = $ 50   format=$char50.   informat=$char50.   label = 'Dosage Form Name csv';
    attrib ROUTENAME                        length = $ 160  format=$char160.  informat=$char160.  label = 'Route Name ssv';
    attrib STARTMARKETINGDATE               length = 8      format=yymmdd10.  informat=yymmdd8.   label = 'Start Marketing Date';
    attrib ENDMARKETINGDATE                 length = 8      format=yymmdd10.  informat=yymmdd8.   label = 'End Marketing Date';
    attrib MARKETINGCATEGORYNAME            length = $ 40   format=$char40.   informat=$char40.   label = 'Marketing Category Name';
    attrib APPLICATIONNUMBER                length = $ 20   format=$char20.   informat=$char20.   label = 'Application Number';
    attrib LABELERNAME                      length = $ 140  format=$char140.  informat=$char140.  label = 'Labeler Name';
    attrib _SUBSTANCENAME                   length = $ 4000 format=$char4000. informat=$char4000. label = 'SUBSTANCENAME ssv';
    attrib _ACTIVE_NUMERATOR_STRENGTH       length = $ 800  format=$char800.  informat=$char800.  label = 'ACTIVE_NUMERATOR_STRENGTH ssv';
    attrib _ACTIVE_INGRED_UNIT              length = $ 2100 format=$char2100. informat=$char2100. label = 'ACTIVE_INGRED_UNIT ssv';
    attrib _PHARM_CLASSES                   length = $ 4000 format=$char4000. informat=$char4000. label = 'PHARM_CLASSES csv';
    attrib DEASCHEDULE                      length = $ 6    format=$char6.    informat=$char6.    label = 'DEA Schedule';
    attrib NDC_EXCLUDE_FLAG                 length = $ 1    format=$1.        informat=$char1.    label = 'NDC Exclude Flag';
    attrib LISTING_RECORD_CERTIFIED_THRU    length = 8      format=yymmdd10.  informat=yymmdd8.   label = 'Listing record Certified Through Date';
    attrib SUBSTANCENAME                    length = $ 140  format=$char140.  informat=$char140.  label = 'Substance Name';
    attrib ACTIVE_NUMERATOR_STRENGTH        length = $ 16   format=$char16.   informat=$char16.   label = 'Strength Number';
    attrib ACTIVE_INGRED_UNIT               length = $ 20   format=$char20.   informat=$char20.   label = 'Strength Unit';
    attrib PHARM_CLASSES                    length = $ 100  format=$char100.  informat=$char100.  label = 'Pharmacological Class';
    infile ndc(product.txt) dlm = '09'x dsd lrecl = 8192 missover firstobs = 2;
    input
        PRODUCTID $
        PRODUCTNDC $
        PRODUCTTYPENAME $
        PROPRIETARYNAME $
        PROPRIETARYNAMESUFFIX $
        NONPROPRIETARYNAME $
        DOSAGEFORMNAME $
        ROUTENAME $
        STARTMARKETINGDATE
        ENDMARKETINGDATE
        MARKETINGCATEGORYNAME $
        APPLICATIONNUMBER $
        LABELERNAME $
        _SUBSTANCENAME $
        _ACTIVE_NUMERATOR_STRENGTH $
        _ACTIVE_INGRED_UNIT $
        _PHARM_CLASSES $
        DEASCHEDULE $
        NDC_EXCLUDE_FLAG $
        LISTING_RECORD_CERTIFIED_THRU
        ;
    output FDA.product;
    SEQNO = 1;
    SubstanceName = scan( _SubstanceName, SEQNO, ';' );
    do while( not( missing( SubstanceName ) ) );
        Active_Numerator_Strength = left( scan( _Active_Numerator_Strength, SEQNO, ';' ) );
        Active_Ingred_Unit = left( scan( _Active_Ingred_Unit, SEQNO, ';' ) );
        Pharm_Classes = left( scan( _Pharm_Classes, SEQNO, ',' ) );
        output FDA.substance;
        SEQNO + 1;
        SubstanceName = left( scan( _SubstanceName, SEQNO, ';' ) );
        end;
    run;

data package;
    attrib PRODUCTID          length = $ 50  format=$char50.   informat=$char50.  label = 'PRODUCTID';
    attrib PRODUCTNDC         length = $ 15  format=$char15.   informat=$char15.  label = 'PRODUCTNDC';
    attrib NDCPACKAGECODE     length = $ 20  format=$char20.   informat=$char20.  label = 'NDCPACKAGECODE';
    attrib STARTMARKETINGDATE length = 8     format=yymmdd10.  informat=yymmdd8.  label = 'STARTMARKETINGDATE';
    attrib ENDMARKETINGDATE   length = 8     format=yymmdd10.  informat=yymmdd8.  label = 'ENDMARKETINGDATE';
    attrib NDC_EXCLUDE_FLAG   length = $ 1   format=$1.        informat=$1.       label = 'NDC_EXCLUDE_FLAG';
    attrib SAMPLE_PACKAGE     length = $ 1   format=$1.        informat=$1.       label = 'SAMPLE_PACKAGE';
    attrib PACKAGEDESCRIPTION length = $ 800 format=$char800.  informat=$char800. label = 'PACKAGEDESCRIPTION';
    infile ndc(package.txt) dlm = '09'x dsd lrecl = 2048 missover firstobs = 2;
    input
        PRODUCTID $
        PRODUCTNDC $
        NDCPACKAGECODE $
        PACKAGEDESCRIPTION $
        STARTMARKETINGDATE
        ENDMARKETINGDATE
        NDC_EXCLUDE_FLAG $
        SAMPLE_PACKAGE $
        ;
run;

proc sort data = package;
    by NDCPackageCode PRODUCTNDC STARTMARKETINGDATE ENDMARKETINGDATE NDC_EXCLUDE_FLAG SAMPLE_PACKAGE PACKAGEDESCRIPTION productID;
run;

data package( drop = _: );
    set package( rename = ( PRODUCTID = _ ) );
    by NDCPackageCode PRODUCTNDC STARTMARKETINGDATE ENDMARKETINGDATE NDC_EXCLUDE_FLAG SAMPLE_PACKAGE PACKAGEDESCRIPTION;
    length productIDs $ 150;
    retain productIDs;
    if first.PACKAGEDESCRIPTION then productIDs  = _;
    else productIDs = catt( productIDs, '+', _ );
    if last.PACKAGEDESCRIPTION then output;
run;

proc sort data = package;
    by NDCPackageCode PRODUCTNDC STARTMARKETINGDATE ENDMARKETINGDATE NDC_EXCLUDE_FLAG SAMPLE_PACKAGE PACKAGEDESCRIPTION;
run;

data package( drop = _: );
    set package( rename = ( PACKAGEDESCRIPTION = _ ) );
    by NDCPackageCode PRODUCTNDC STARTMARKETINGDATE ENDMARKETINGDATE NDC_EXCLUDE_FLAG SAMPLE_PACKAGE;
    length PackageDescriptions $ 1600;
    retain PackageDescriptions;
    if first.Sample_Package then PackageDescriptions  = _;
    else PackageDescriptions = catt( PackageDescriptions, '#+#', _ );
    if last.Sample_Package then output;
run;

proc sort data = package;
    by NDCPackageCode StartMarketingDate;
run;

data FDA.package_dups FDA.package_latest;
    set package;
    by NDCPackageCode;
    if not( first.NDCPackageCode & last.NDCPackageCode ) then output FDA.package_dups;
    if last.NDCPackageCode then output FDA.package_latest;
run;

proc print data = FDA.package_dups;
run;
/* EOF Jack N Shoemaker (JShoemaker@TextureHealth.com) */
