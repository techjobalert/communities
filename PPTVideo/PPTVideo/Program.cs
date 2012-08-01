using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.Office.Core;
using PowerPoint = Microsoft.Office.Interop.PowerPoint;
using System.Runtime.InteropServices;
using System.IO;
using Microsoft.Office.Interop.PowerPoint;

// Based on article
// http://support.microsoft.com/kb/303718

namespace PPTVideo
{
    class Program
    {
        static PowerPoint.Application objApp;
        static float ANIMATION_DELAY = 0.017f;
        static float TRANSITION_DELAY = 0.085f;
        static float DEFAULT_SLIDE_DURATION = 5f;
        static float DEFAULT_ANIMATION_DURATION = 0.5f;

        static float calcSlide(Slide slide)
        {
            SlideShowTransition sst = slide.SlideShowTransition;
            TimeLine timeline = slide.TimeLine;
            Sequence sequence = timeline.MainSequence;

            int animationsNumber = sequence.Count;
            float animTime = 0;
            if (animationsNumber != 0)
            {
                LinkedList<Timing> timeList = new LinkedList<Timing>();
                //Calculate animation duration time to next click on the same slide
                for (int i = 1; i <= animationsNumber; i++)
                {
                    Effect effect = sequence[i];
                    Timing timing = effect.Timing;

                    timeList.AddLast(timing);
                }
                animTime = calcTimings(timeList);
            }
            return animTime;
        }

        static float calcTimings(LinkedList<Timing> timeList)
        {
            Dictionary<int, float> startTime = new Dictionary<int, float>();
            Dictionary<int, float> durationTime = new Dictionary<int, float>();

            Timing timing = null;
            bool hasClickableAnimation = false;

            for (int i = 0; i < timeList.Count; i++)
            {
                timing = timeList.ElementAt(i);
                durationTime.Add(i, timing.Duration <= 0.01f ? DEFAULT_ANIMATION_DURATION : timing.Duration);
            }

            float duration = 0;
            float maxDuration = 0;
            startTime.Add(0, 0);

            for (int i = 0; i < timeList.Count; i++)
            {
                timing = timeList.ElementAt(i);

                duration = startTime[i] + durationTime[i] + timing.TriggerDelayTime;

                if (timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerOnPageClick)
                {
                    hasClickableAnimation = true;
                }

                if (timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerOnPageClick
                    || timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerAfterPrevious)
                {
                    maxDuration = duration;   
                    startTime.Add(i + 1, duration);
                }
                else if (timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerWithPrevious)
                {
                    startTime[i] = i > 0 ? startTime[i - 1] : 0;
                    duration = startTime[i] + durationTime[i] + timing.TriggerDelayTime;
                    maxDuration = duration > maxDuration ? duration : maxDuration;
                    startTime.Add(i + 1, maxDuration);
                }
            }

            return hasClickableAnimation ? startTime.Values.Max() : 0;
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

        static void printOut(LinkedList<float> timeList, String fileName)
        {
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(fileName, false))
            {
                foreach (float time in timeList)
                {
                    file.WriteLine(time + " --> " + getTimeFormat(time));
                }
            }  
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

                if (args.Length > 2)
                {
                    try
                    {
                        ANIMATION_DELAY = Math.Abs(float.Parse(args[2]));
                    }
                    catch (FormatException e)
                    { }
                }

                Console.Out.WriteLine("ANIMATION_DELAY was set to " + ANIMATION_DELAY);
                Console.Out.WriteLine("TRANSITION_DELAY was set to " + TRANSITION_DELAY);
                Console.Out.WriteLine("DEFAULT_SLIDE_DURATION was set to " + DEFAULT_SLIDE_DURATION);
                Console.Out.WriteLine("DEFAULT_ANIMATION_DURATION was set to " + DEFAULT_ANIMATION_DURATION);

                PowerPoint._Presentation objPres;
                objApp = new PowerPoint.Application();
                objPres = objApp.Presentations.Open(Path.GetFullPath(args[0]), MsoTriState.msoTrue, MsoTriState.msoTrue, MsoTriState.msoTrue);

                float time = 0.0F;
                Slides slides = objPres.Slides;


                LinkedList<float> timeList = new LinkedList<float>();
                Console.Out.WriteLine("Start Time=" + getTimeFormat(time) + " [" + time + "]");
                float lastTiming = 0;

                for (int s = 1; s <= slides.Count; s++)
                {
                    Slide slide = slides[s];

                    PPTSlide pptslide = new PPTSlide(slide);
                    if (s == 1)
                    {
                        pptslide.addSlideTransitionTime(PPTSlide.TRANSITION_DELAY);
                    }

                    pptslide.calcSlide();

                    timeList = new LinkedList<float>(timeList.Concat(pptslide.addTimeShift(lastTiming)));
                    lastTiming = timeList.Last.Value;  

                    if (!pptslide.clickableTransition)
                    {                  
                        timeList.RemoveLast();
                    }
                }

                //timeList.RemoveLast();

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

                Console.Out.WriteLine("Timing file created: " + args [1] +".txt");

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

        static int oldcalc(string[] args)
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

                if (args.Length > 2)
                {
                    try
                    {
                        ANIMATION_DELAY = Math.Abs(float.Parse(args[2]));
                    }
                    catch (FormatException e)
                    { }
                }

                Console.Out.WriteLine("ANIMATION_DELAY was set to " + ANIMATION_DELAY);
                Console.Out.WriteLine("TRANSITION_DELAY was set to " + TRANSITION_DELAY);
                Console.Out.WriteLine("DEFAULT_SLIDE_DURATION was set to " + DEFAULT_SLIDE_DURATION);
                Console.Out.WriteLine("DEFAULT_ANIMATION_DURATION was set to " + DEFAULT_ANIMATION_DURATION);

                PowerPoint._Presentation objPres;
                objApp = new PowerPoint.Application();
                objPres = objApp.Presentations.Open(Path.GetFullPath(args[0]), MsoTriState.msoTrue, MsoTriState.msoTrue, MsoTriState.msoTrue);

                float time = 0.0F;
                Slides slides = objPres.Slides;
                LinkedList<float> timeList = new LinkedList<float>();
                //timeList.AddFirst(time);
                Console.Out.WriteLine("Start Time=" + getTimeFormat(time) + " [" + time + "]");

                for (int s = 1; s <= slides.Count; s++)
                {
                    Slide slide = slides[s];

                    SlideShowTransition sst = slide.SlideShowTransition;
                    TimeLine timeline = slide.TimeLine;

                    int animationsNumber = timeline.MainSequence.Count;
                    float changeSlideDelay = sst.AdvanceTime;
                    float changeSlideDuration = sst.Duration;

                    time += TRANSITION_DELAY;
                    if (sst.EntryEffect != PpEntryEffect.ppEffectNone)
                    {
                        time += TRANSITION_DELAY;

                        if (animationsNumber == 0)
                        {
                            changeSlideDuration += DEFAULT_SLIDE_DURATION;
                            time += changeSlideDuration;
                        }
                        else
                        {
                            time += changeSlideDuration;
                        }
                    }

                    if (animationsNumber != 0)
                    {

                        float timeAroundAnimation = 0;
                        float animationTotalTimeInSlide = 0;

                        PPTSlide pptslide = new PPTSlide(slide);

                        animationTotalTimeInSlide = pptslide.calcSlide();

                        if (animationTotalTimeInSlide < DEFAULT_SLIDE_DURATION
                            && animationTotalTimeInSlide > 0)
                        {
                            timeAroundAnimation = (DEFAULT_SLIDE_DURATION - animationTotalTimeInSlide) / 2;
                        }

                        time += timeAroundAnimation;

                        //Calculate animation duration time to next click on the same slide
                        for (int i = 1; i <= timeline.MainSequence.Count; i++)
                        {
                            Effect effect = timeline.MainSequence[i];
                            Timing timing = effect.Timing;
                            float animationDelay = timing.TriggerDelayTime;
                            float animationDuration = timing.Duration < 0.01f ? DEFAULT_ANIMATION_DURATION : timing.Duration;

                            if (timeline.MainSequence[i].Timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerOnPageClick)
                            {
                                if (timeList.Count == 0 || timeList.Last.Value < time)
                                {
                                    if (i == 1)
                                    {
                                        time += ANIMATION_DELAY;
                                    }

                                    timeList.AddLast(time);
                                    Console.Out.WriteLine("Time=" + getTimeFormat(time) + " [" + time + "]");
                                }
                            }

                            Console.Out.WriteLine("    MainSequence TriggerDelayTime :" + animationDelay + ", Duration: " + animationDuration + ", Type: " + timing.TriggerType);

                            int j = 0;
                            List<float> animationTimeList = new List<float>();
                            animationTimeList.Add(animationDelay + animationDuration);
                            float totalAnimationTime = 0;
                            totalAnimationTime += animationDelay + animationDuration;

                            //Looking at the next animation to find WithPrevious or AfterPrevious
                            if (((i + 1) <= timeline.MainSequence.Count) && (timeline.MainSequence[i + 1].Timing.TriggerType != MsoAnimTriggerType.msoAnimTriggerOnPageClick))
                            {
                                bool endFlag = false;
                                for (j = i + 1; j <= timeline.MainSequence.Count; j++)
                                {
                                    Console.Out.WriteLine("    MainSequence TriggerDelayTime :" + animationDelay + ", Duration: " + animationDuration + ", Type: " + timing.TriggerType);
                                    if (timeline.MainSequence[i + 1].Timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerWithPrevious)
                                    {
                                        if (timeline.MainSequence[j].Timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerWithPrevious)
                                        {
                                            animationTimeList.Add(timeline.MainSequence[j].Timing.TriggerDelayTime
                                                + (timeline.MainSequence[j].Timing.Duration <= 0.01f ? DEFAULT_ANIMATION_DURATION : timing.Duration));

                                            float tempTime = timeline.MainSequence[j].Timing.TriggerDelayTime
                                                + (timeline.MainSequence[j].Timing.Duration <= 0.01f ? DEFAULT_ANIMATION_DURATION : timing.Duration);
                                            totalAnimationTime = tempTime > totalAnimationTime ? tempTime : totalAnimationTime;
                                        }
                                        else
                                            endFlag = true;
                                    }
                                    else if (timeline.MainSequence[i + 1].Timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerAfterPrevious)
                                    {
                                        if (timeline.MainSequence[j].Timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerAfterPrevious)
                                        {
                                            animationTimeList[animationTimeList.Count - 1] += (timeline.MainSequence[j].Timing.TriggerDelayTime
                                                + (timeline.MainSequence[j].Timing.Duration <= 0.01f ? DEFAULT_ANIMATION_DURATION : timing.Duration));

                                            totalAnimationTime += (timeline.MainSequence[j].Timing.TriggerDelayTime
                                                + (timeline.MainSequence[j].Timing.Duration <= 0.01f ? DEFAULT_ANIMATION_DURATION : timing.Duration));
                                        }
                                        else
                                            endFlag = true;
                                    }
                                    else
                                    {
                                        endFlag = true;
                                    }

                                    if (endFlag || j == timeline.MainSequence.Count)
                                    {
                                        i = j - 1;
                                        //time += animationTimeList.Max();

                                        time += totalAnimationTime;

                                        if (timeList.Count == 0 || timeList.Last.Value < time)
                                        {
                                            timeList.AddLast(time);
                                            Console.Out.WriteLine("Time=" + getTimeFormat(time) + " [" + time + "]");
                                        }
                                        endFlag = false;
                                        break;
                                    }
                                }
                            }//END Looking at the next animation to find WithPrevious or AfterPrevious
                            else
                            {
                                animationTimeList.Add(animationDelay + animationDuration);
                                //time += animationTimeList.Max();
                                time += totalAnimationTime;
                            }

                        }//END Calculate animation duration time to next click on the same slide

                        time += timeAroundAnimation;
                    }

                    if (sst.AdvanceOnClick == MsoTriState.msoTrue && s < slides.Count)
                    {
                        if (timeList.Count == 0 || timeList.Last.Value < time)
                        {
                            //time += TRANSITION_DELAY;
                            timeList.AddLast(time);
                            Console.Out.WriteLine("Time=" + getTimeFormat(time) + " [" + time + "]");
                        }
                    }
                    else
                    {
                        time += changeSlideDelay;
                    }
                }



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

                printOut(timeList, args[1] + ".txt");


            }
            catch (Exception e)
            {
                System.Console.WriteLine("Error: " + e.Message);
                //Console.In.ReadLine();
                return 1;
            }
            // Console.In.ReadLine();
            return 0;
        }
    }
}