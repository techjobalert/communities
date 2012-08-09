using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.Office.Core;
using PowerPoint = Microsoft.Office.Interop.PowerPoint;
using System.Runtime.InteropServices;
using System.IO;
using Microsoft.Office.Interop.PowerPoint;

namespace PPTVideo
{
    class Program
    {
        static PowerPoint.Application objApp;
        static float DEFAULT_SLIDE_DURATION = 5f;
        static float defaultAnimationDelay = 0.5f;
        static float defaultAnimationDuration = 0.5f;
        static float defaultTransitionDuration = 1.0f;

        
        static void printOut(List<float> timeList, String fileName)
        {
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(fileName, false))
            {
                foreach (float time in timeList)
                {
                    file.WriteLine("0 --> " + getTimeFormat(time)); //milliseconds
                }
            }
        }

        static String getTimeFormat(float time)
        {
            // --> 00:00:18,873

            double milliseconds = time - Math.Floor(time);
            double seconds = Math.Floor(Math.Floor(time) % 60);
            double minutes = Math.Floor((time / 60.0) % 60);
            double hours = Math.Floor((time / 3600.0) % 60);

            milliseconds = Math.Round(milliseconds*1000.0, 0);
            
            String str = "00:00:00.000";
            str = (hours < 10 ? (String)("0" + hours) : (String)(hours + ""))
                 + ":" + (minutes < 10 ? (String)("0" + minutes) : (String)(minutes + ""))
                 + ":" + (seconds < 10 ? (String)("0" + seconds) : (String)(seconds + ""))
                 + "," + (milliseconds == 0 ? "000" : 
                    (milliseconds < 10 ? (String)("00" + milliseconds) :
                        (milliseconds < 100 ? (String)("0" + milliseconds) : (String)(milliseconds + ""))));
            
            return str;
        }

        static int Main(string[] args)
        {
            string usage = "Usage: PPTVideo.exe <infile> <outfile> <animation delay in sec. Float value> [-d]";

            try
            {
                if (args.Length < 2)
                {
                    Console.Out.WriteLine("Wrong argument number");
                    Console.In.ReadLine();
                    throw new ArgumentException("Wrong number of arguments.\n" + usage);
                }

                PowerPoint._Presentation objPres;
                objApp = new PowerPoint.Application();
                objPres = objApp.Presentations.Open(Path.GetFullPath(args[0]), MsoTriState.msoTrue, MsoTriState.msoTrue, MsoTriState.msoTrue);

                Slides slides = objPres.Slides;

                List<float> timeList = new List<float>();
                
                for (int s = 1; s <= slides.Count; s++)
                {

                    addSlideTimings(slides[s], timeList);
                }

                timeList.RemoveAt(timeList.Count - 1);

                printOut(timeList, args[1] + ".txt");

                objPres.SaveAs(Path.GetFullPath(args[1]), PowerPoint.PpSaveAsFileType.ppSaveAsWMV, MsoTriState.msoTriStateMixed);
                long len = 0;
                do
                {
                    System.Threading.Thread.Sleep(500);
                    try
                    {
                        FileInfo f = new FileInfo(args[1]);
                        len = f.Length;
                    }
                    catch
                    {
                        continue;
                    }
                } while (len == 0);


                objApp.Quit();

                Console.Out.WriteLine("Timing file created: " + args[1] + ".txt");

                //
                // Check if we want to delete the input file
                //
                if (args.Length > 3 && args[3] == "-d")
                    File.Delete(args[0]);

            }
            catch (Exception e)
            {
                System.Console.WriteLine("Error: " + e.Message);
                return 1;
            }
            // Console.In.ReadLine();
            return 0;
        }

        private static void addSlideTimings(Slide slide, List<float> result)
        {
            SlideShowTransition sst = slide.SlideShowTransition;
            Sequence sequence = slide.TimeLine.MainSequence;

            float slideStart = 0f;

            if (result.Count > 0)
            {
                sst.Duration = defaultTransitionDuration;
                slideStart = result.Last() + defaultTransitionDuration;
                result.Add(slideStart);
            }
            
            if (sequence.Count > 0)
            {
                for (int i = 1; i <= sequence.Count; i++)
                {
                    Effect effect = sequence[i];
                    Timing timing = effect.Timing;

                    float animationDelay = timing.TriggerDelayTime;
                    float animationDuration = timing.Duration;

                    if( animationDelay <= 0 ) {
                        animationDelay = defaultAnimationDelay;
                        timing.TriggerDelayTime = defaultAnimationDelay;
                    }

                    if (animationDuration <= 0)
                    {
                        animationDuration = defaultAnimationDuration;
                        timing.Duration = defaultAnimationDuration;
                    }

                    timing.TriggerType = MsoAnimTriggerType.msoAnimTriggerAfterPrevious;

                    if (effect.EffectInformation.TextUnitEffect == MsoAnimTextUnitEffect.msoAnimTextUnitEffectByCharacter)
                    {
                        animationDuration = animationDuration * getCharactersCount(effect.DisplayName);
                    }

                    if (effect.EffectInformation.TextUnitEffect == MsoAnimTextUnitEffect.msoAnimTextUnitEffectByWord)
                    {
                        animationDuration = animationDuration * effect.DisplayName.Split(' ').Length;
                    }

                    float lastPoint = result.Count > 0 ? result.Last() : 0;

                    result.Add(lastPoint + animationDelay + animationDuration);
                }

            }

            float currentPoint = result.Count > 0 ? result.Last() : 0;

            float averallAnimationDuration = currentPoint - slideStart;
            
            // 1 - transition time
            double actualSlideDuration = DEFAULT_SLIDE_DURATION * (Math.Floor((double)averallAnimationDuration / (double)DEFAULT_SLIDE_DURATION) + 1); // 5, 10, 15 ...
            sst.AdvanceOnTime = MsoTriState.msoTrue;
            sst.AdvanceOnClick = MsoTriState.msoFalse;
            sst.AdvanceTime = (float)actualSlideDuration;

            result.Add(slideStart + (float)actualSlideDuration);
        }

        private static int getCharactersCount(string text)
        {
            int count = 0;
            foreach (char c in text)
            {
                if (char.IsLetter(c))
                {
                    count++;
                }
            }
            return count;
        }
    }


}