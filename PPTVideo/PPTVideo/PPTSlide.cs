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
    class PPTSlide
    {
        public static float ANIMATION_DELAY = 0.017f;
        public static float TRANSITION_DELAY = 0.085f;
        public static float DEFAULT_SLIDE_DURATION = 5f;
        public static float DEFAULT_ANIMATION_DURATION = 0.5f;

        
        public Dictionary<int, float> startTime = new Dictionary<int, float>();
        public Dictionary<int, float> durationTime = new Dictionary<int, float>();
        public Dictionary<int, float> clickTime = new Dictionary<int, float>();
        public LinkedList<float> slideTiming = new LinkedList<float>();
        public bool clickableTransition = true;

        private float slideTransitionTime = 0;
        private Slide slideInternal = null;
        private float changeSlideDuration = 0;
        private float changeSlideDelay = 0;
        private PPTSlide(){}

        public PPTSlide(Slide slide)
        {
            slideInternal = slide;

            SlideShowTransition sst = slideInternal.SlideShowTransition;
            TimeLine timeline = slideInternal.TimeLine;

            int animationsNumber = timeline.MainSequence.Count;
            changeSlideDelay = sst.AdvanceTime;
            changeSlideDuration = sst.Duration;

            //calculate slide transition

            if (sst.AdvanceOnClick == MsoTriState.msoTrue)
            {
                clickableTransition = true;
            }
            else
            {
                clickableTransition = false;
            }


            if (sst.EntryEffect != PpEntryEffect.ppEffectNone)
            {
                
                slideTransitionTime += TRANSITION_DELAY;
            }
            else
            {
                changeSlideDuration = 0;

            }

            slideTransitionTime += changeSlideDuration;
            //slideTransitionTime += TRANSITION_DELAY;
        }

        public void addSlideTransitionTime(float time){
            slideTransitionTime += time;
        }

        public float calcSlide()
        {
            SlideShowTransition sst = slideInternal.SlideShowTransition;
            TimeLine timeline = slideInternal.TimeLine;
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

            float beforeAfterAnimation = 0;

            float slideDuration = changeSlideDelay > DEFAULT_SLIDE_DURATION ? changeSlideDelay : DEFAULT_SLIDE_DURATION;

            if (animTime >= 0 && animTime < slideDuration)
            {
                beforeAfterAnimation = ((slideDuration - animTime) / 2);
            }

            //if (animTime > slideDuration)
            //{
            //    beforeAfterAnimation = animTime;

            //}


            slideTransitionTime += beforeAfterAnimation;
            updateClickTime();

            if (slideTiming.Count == 0)
            {
                slideTiming.AddLast(slideDuration + slideTransitionTime - beforeAfterAnimation);
            }
            else
            {
                if (slideTiming.Last.Value < (slideTiming.Last.Value + beforeAfterAnimation))
                {
                    slideTiming.AddLast(slideTiming.Last.Value + beforeAfterAnimation);
                }
            }

            return animTime;
        }

        private void updateClickTime()
        {
            foreach (int i in clickTime.Keys)
            {
                if (clickTime[i] > 0 || (clickTime[i] == 0 && slideTiming.Count == 0))
                {
                    slideTiming.AddLast(clickTime[i] + slideTransitionTime);
                }
            }
            //for (int i = 0; i < clickTime.Keys.Count; i++)
            //{
            //    if (clickTime[i] > 0 || (clickTime[i] == 0 && slideTiming.Count == 0))
            //    {
            //        slideTiming.AddLast(clickTime[i] + slideTransitionTime);
            //    }
            //}
        }

        public LinkedList<float> addTimeShift(float shift)
        {
            LinkedList<float> resultTiming = new LinkedList<float>();
            for (int i=0; i<slideTiming.Count; i++)
            {
                resultTiming.AddLast(slideTiming.ElementAt(i) + shift);
            }

            return resultTiming;
        }

        private float calcTimings(LinkedList<Timing> timeList)
        {
            Timing timing = null;
            bool isClickableOrAfterPrevAnimation = false;
            float duration = 0;

            for (int i = 0; i < timeList.Count; i++)
            {
                timing = timeList.ElementAt(i);
                duration = timing.Duration <= 0.01f ? 0 : timing.Duration;
                duration += timing.TriggerDelayTime;
                if (duration <= 0)
                {
                    duration = DEFAULT_ANIMATION_DURATION;
                }

                durationTime.Add(i, duration);
            }

            float maxDuration = 0;
            startTime.Add(0, 0);

            try
            {
                for (int i = 0; i < timeList.Count; i++)
                {
                    timing = timeList.ElementAt(i);

                    duration = startTime[i] + durationTime[i];

                    if (timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerOnPageClick)
                    {
                        if (i == 0)
                        {
                            duration += ANIMATION_DELAY;
                            //clickTime.Remove(0);
                        }
                        isClickableOrAfterPrevAnimation = true;
                        clickTime.Add(i, duration);
                    }

                    if (timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerOnPageClick
                        || timing.TriggerType == MsoAnimTriggerType.msoAnimTriggerAfterPrevious)
                    {
                        isClickableOrAfterPrevAnimation = true;
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
            }
            catch (Exception ae)
            {
                System.Console.WriteLine("Error: " + ae.Message);
            }

            return isClickableOrAfterPrevAnimation ? startTime.Values.Max() : 0;
        }

    }
}
