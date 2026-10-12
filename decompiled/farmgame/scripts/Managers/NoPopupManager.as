package Managers
{
   import Classes.Constants.Experiments;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   import Widgets.Windows.MOTD.CustomWindowMOTDBase;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   
   public class NoPopupManager
   {
      
      private static const TRACKING_POPUPS_TIME_PERIOD:int = 10000;
      
      private static const POPUP_DETAILS:String = "popup_details";
      
      private static const NUMBER_POPUPS_TO_BE_SHOWN:int = 1;
      
      private static const POPUP_NAME:String = "popup_name";
      
      public static const NOPOPUPS_COUNTER:String = "no_popups";
      
      private var m_isEligibleForNoPopups:Boolean;
      
      private var m_canDisplayPopup:Boolean = true;
      
      private var m_priorityPopUps:Array = new Array();
      
      private var m_motd:Array = new Array();
      
      private var m_priorityList:Array = new Array();
      
      private var m_resetSupress:Boolean;
      
      private var m_startTracking:Boolean = false;
      
      private var m_timer:Timer;
      
      public function NoPopupManager()
      {
         super();
      }
      
      public function setIsEligibleForNoPopups(isEligible:Boolean) : void
      {
         this.m_isEligibleForNoPopups = isEligible;
         if(Global.flashHotParams["INITIAL_POPUP_PRIORITY"])
         {
            this.m_priorityList = Global.flashHotParams["INITIAL_POPUP_PRIORITY"].split(",");
         }
         this.m_canDisplayPopup = true;
         this.m_resetSupress = false;
      }
      
      public function isEligible() : Boolean
      {
         var hide:Boolean = false;
         if(this.m_isEligibleForNoPopups && this.inExperiment())
         {
            hide = true;
         }
         return hide;
      }
      
      public function canDisplayPopup(displayObj:DisplayObject, addToQueue:Boolean = true, popupName:String = "", checkDuplicates:Boolean = false, forceAddToQueueStart:Boolean = false) : Boolean
      {
         var dispObjName:String = getQualifiedClassName(displayObj);
         var popupWindowDetails:Array = new Array();
         var motdDetails:Array = new Array();
         var index:int = -1;
         var dispObjArr:Array = dispObjName.split("::");
         dispObjName = dispObjArr[dispObjArr.length - 1];
         if(this.isEligible())
         {
            if(this.m_startTracking)
            {
               FarmStatsManager.count(NoPopupManager.NOPOPUPS_COUNTER,"postSuppressNoPopups",dispObjName);
            }
            if(!this.m_resetSupress)
            {
               this.negateDisableInputCount();
               this.m_canDisplayPopup = false;
               if(displayObj is CustomWindowMOTDBase || displayObj is ExpansionOnboardingWindow)
               {
                  motdDetails.push({
                     "displayObj":displayObj,
                     "addToQueue":addToQueue,
                     "popupName":popupName,
                     "checkDuplicates":checkDuplicates,
                     "forceAddToQueueStart":forceAddToQueueStart
                  });
                  this.m_motd.push({
                     "popup_name":dispObjName,
                     "popup_details":motdDetails
                  });
               }
               else if(Boolean(this.m_priorityList) && this.m_priorityList.length > 0)
               {
                  index = this.m_priorityList.indexOf(dispObjName);
                  if(index >= 0)
                  {
                     popupWindowDetails.push({
                        "displayObj":displayObj,
                        "addToQueue":addToQueue,
                        "popupName":popupName,
                        "checkDuplicates":checkDuplicates,
                        "forceAddToQueueStart":forceAddToQueueStart
                     });
                     this.m_priorityPopUps[index] = {
                        "popup_name":dispObjName,
                        "popup_details":popupWindowDetails
                     };
                  }
                  else
                  {
                     FarmStatsManager.count(NoPopupManager.NOPOPUPS_COUNTER,"suppressed_v1",dispObjName);
                  }
               }
               else
               {
                  FarmStatsManager.count(NoPopupManager.NOPOPUPS_COUNTER,"suppressedNotInRuntime_v1",dispObjName);
               }
            }
            else
            {
               this.m_canDisplayPopup = true;
            }
         }
         return this.m_canDisplayPopup;
      }
      
      private function negateDisableInputCount() : void
      {
         if(!InputManager.isInputEnabled())
         {
            InputManager.enableInput();
         }
      }
      
      public function resetSupress() : void
      {
         var m_details:Object = null;
         var popupName:String = null;
         var popup_to_be_shown:Object = null;
         var popupsPriorityOrdered:Array = null;
         var i:int = 0;
         if(this.isEligible())
         {
            m_details = null;
            popupName = "";
            popup_to_be_shown = null;
            popupsPriorityOrdered = null;
            this.m_resetSupress = true;
            this.m_canDisplayPopup = true;
            if(Boolean(this.m_priorityPopUps) && this.m_priorityPopUps.length > 0)
            {
               popupsPriorityOrdered = this.m_priorityPopUps.reverse();
            }
            for(i = 0; i < NUMBER_POPUPS_TO_BE_SHOWN; i++)
            {
               if(Boolean(popupsPriorityOrdered) && popupsPriorityOrdered.length > 0)
               {
                  popup_to_be_shown = popupsPriorityOrdered.pop();
                  this.showThePopup(popup_to_be_shown);
               }
               else if(Boolean(this.m_motd) && this.m_motd.length > 0)
               {
                  popup_to_be_shown = this.m_motd.pop();
                  this.showThePopup(popup_to_be_shown);
               }
            }
            if(popupsPriorityOrdered)
            {
               while(popupsPriorityOrdered.length > 0)
               {
                  popup_to_be_shown = popupsPriorityOrdered.pop();
                  if(popup_to_be_shown)
                  {
                     m_details = popup_to_be_shown[POPUP_DETAILS][0];
                     popupName = popup_to_be_shown[POPUP_NAME];
                     FarmStatsManager.count(NoPopupManager.NOPOPUPS_COUNTER,"suppressed_runtime_v1",popupName);
                  }
               }
            }
            this.startTrackingPostResetSuppress();
         }
      }
      
      private function startTrackingPostResetSuppress() : void
      {
         this.m_startTracking = true;
         this.m_timer = new Timer(TRACKING_POPUPS_TIME_PERIOD,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.stopTracking);
         this.m_timer.start();
      }
      
      private function stopTracking(e:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.stopTracking);
            this.m_startTracking = false;
         }
      }
      
      private function showThePopup(popup_to_be_shown:Object = null) : void
      {
         var m_details:Object = null;
         var popupName:String = "";
         if(popup_to_be_shown)
         {
            m_details = popup_to_be_shown[POPUP_DETAILS][0];
            popupName = popup_to_be_shown[POPUP_NAME];
         }
         if(m_details)
         {
            FarmStatsManager.count(NoPopupManager.NOPOPUPS_COUNTER,"not_suppressed_runtime_v1",popupName);
            UI.displayPopup(m_details["displayObj"],false,m_details["popupName"],m_details["checkDuplicates"],m_details["forceAddToQueueStart"]);
            UI.stopPopups(false);
         }
      }
      
      public function inExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_NOPOPUP_FOR_REACTS) >= 3;
      }
   }
}

