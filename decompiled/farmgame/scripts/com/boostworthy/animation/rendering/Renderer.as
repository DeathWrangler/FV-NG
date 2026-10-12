package com.boostworthy.animation.rendering
{
   import com.boostworthy.core.Global;
   import com.boostworthy.core.IDisposable;
   import com.boostworthy.utils.logger.ILog;
   import com.boostworthy.utils.logger.LogFactory;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Renderer extends EventDispatcher implements IDisposable
   {
      
      protected var m_fncOnEnterFrame:Function;
      
      protected var m_objTimer:Timer;
      
      protected var m_fncOnTimer:Function;
      
      protected var m_objStage:Stage;
      
      protected var m_objLog:ILog;
      
      public function Renderer(param1:Function, param2:Function, param3:Number)
      {
         super();
         if(param1 != null)
         {
            this.m_fncOnEnterFrame = param1;
            this.m_objStage = Global.stage;
         }
         if(param2 != null)
         {
            this.m_fncOnTimer = param2;
            this.m_objTimer = new Timer(param3,0);
            this.m_objTimer.addEventListener(TimerEvent.TIMER,this.m_fncOnTimer);
         }
         this.m_objLog = LogFactory.getInstance().getLog("Renderer");
      }
      
      public function start(param1:Number) : void
      {
         if(param1 == RenderMethod.ENTER_FRAME)
         {
            this.startEnterFrame();
         }
         else if(param1 == RenderMethod.TIMER)
         {
            this.startTimer();
         }
      }
      
      public function stop(param1:Number) : void
      {
         if(param1 == RenderMethod.ENTER_FRAME)
         {
            this.stopEnterFrame();
         }
         else if(param1 == RenderMethod.TIMER)
         {
            this.stopTimer();
         }
      }
      
      public function startAll() : void
      {
         this.startEnterFrame();
         this.startTimer();
      }
      
      public function stopAll() : void
      {
         this.stopEnterFrame();
         this.stopTimer();
      }
      
      public function dispose() : void
      {
         if(this.m_fncOnEnterFrame != null && this.m_objStage != null)
         {
            this.m_objStage.removeEventListener(Event.ENTER_FRAME,this.m_fncOnEnterFrame);
         }
         if(this.m_objTimer != null)
         {
            this.m_objTimer.removeEventListener(TimerEvent.TIMER,this.m_fncOnTimer);
         }
         this.m_fncOnEnterFrame = null;
         this.m_objTimer = null;
         this.m_fncOnTimer = null;
         this.m_objStage = null;
      }
      
      protected function startEnterFrame() : void
      {
         if(!this.m_objStage)
         {
            this.m_objStage = Global.stage;
         }
         if(this.m_objStage)
         {
            this.m_objStage.addEventListener(Event.ENTER_FRAME,this.m_fncOnEnterFrame);
         }
      }
      
      protected function stopEnterFrame() : void
      {
         if(this.m_objStage)
         {
            this.m_objStage.removeEventListener(Event.ENTER_FRAME,this.m_fncOnEnterFrame);
         }
      }
      
      protected function startTimer() : void
      {
         this.m_objTimer.start();
      }
      
      protected function stopTimer() : void
      {
         this.m_objTimer.stop();
      }
   }
}

