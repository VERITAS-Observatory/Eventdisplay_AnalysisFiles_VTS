/* \file  soundings.C
   \brief plot ballon data from soundings measurements compared with CORSIKA and MODTRAN values

*/

void soundings( string iDataFile = "data/sounding.root", bool iMonthly = false )
{
    VAtmosphereSoundings a;
    a.setHeights(1000,30000,1000);
    a.readSoundingsFromRootFile( iDataFile, 50 );
    a.setPlottingRangeHeight( 0., 50. );
    a.read_CORSIKA_Atmosphere( "$VERITAS_EVNDISP_AUX_DIR/Atmospheres/atmprof61.dat", "VERITAS Winter", 4 );
    a.read_CORSIKA_Atmosphere( "$VERITAS_EVNDISP_AUX_DIR/Atmospheres/atmprof62.dat", "VERITAS Summer", 2 );

    // dates of first full moon in September (or late August)
    vector< int > year;
    vector< int > month;
    vector< int > day;
    vector< int > atm;

    year.push_back( 2008 );  month.push_back( 9 ); day.push_back( 15 );
    year.push_back( 2009 );  month.push_back( 9 ); day.push_back( 4 );
    year.push_back( 2010 );  month.push_back( 9 ); day.push_back( 23 );
    year.push_back( 2011 );  month.push_back( 9 ); day.push_back( 12 );
    year.push_back( 2012 );  month.push_back( 8 ); day.push_back( 31 );
    year.push_back( 2013 );  month.push_back( 9 ); day.push_back( 19 ); 
    year.push_back( 2014 );  month.push_back( 9 ); day.push_back( 9 );
    year.push_back( 2015 );  month.push_back( 8 ); day.push_back( 29 ); 
    year.push_back( 2016 );  month.push_back( 9 ); day.push_back( 16 );
    year.push_back( 2017 );  month.push_back( 9 ); day.push_back( 6 ); 
    year.push_back( 2018 );  month.push_back( 8 ); day.push_back( 25 );
    year.push_back( 2019 );  month.push_back( 9 ); day.push_back( 14 );
//    year.push_back( 2020 );  month.push_back( 9 ); day.push_back( 2 ); 

    if( iMonthly )
    {
        for( unsigned int i = 0; i < 12; i++ )
        {
            a.plot_monthly( year, month, day, 29.53, i, "density" );
        }
    }
    // plot monthly for each year
    else
    {
        for( unsigned int i = 0; i < year.size(); i++ )
        {
            cout << "plotting " << year[i] << endl;
            // plot each season from data listed above to July 1st
            a.plot_season( year[i], month[i], day[i], year[i]+1, 7, 1, "density", year[i]*100+month[i] );
            a.plot_season( year[i], month[i], day[i], year[i]+1, 7, 1, "index", -1 );
        }
    }
}
