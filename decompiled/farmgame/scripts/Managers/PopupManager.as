package Managers
{
   import Display.UI;
   import flash.display.DisplayObject;
   
   public class PopupManager
   {
      
      protected static const INACTIVE_USER_TIME:int = 7000;
      
      protected var m_inactiveUserActions:Array = null;
      
      protected var m_inactiveUserActionsTime:Number = 0;
      
      public function PopupManager()
      {
         super();
      }
      
      public function update() : void
      {
         if(null != this.m_inactiveUserActions && !UI.isShowingPopup() && GlobalEngine.currentTime > Global.lastInputTick + INACTIVE_USER_TIME)
         {
            this.processInactiveUserActions();
         }
      }
      
      public function clearInactiveUserActions() : void
      {
         this.m_inactiveUserActionsTime = 0;
         this.m_inactiveUserActions = null;
      }
      
      public function addInactiveUserPopup(popup:DisplayObject, popupName:String = "", checkDuplicates:Boolean = false, showFirst:Boolean = false) : void
      {
         var queueX:int = 0;
         popup.name = popupName;
         var addToQueue:Boolean = true;
         if(null == this.m_inactiveUserActions)
         {
            this.m_inactiveUserActions = new Array();
         }
         if(checkDuplicates)
         {
            for(queueX = 0; queueX < this.m_inactiveUserActions.length; queueX++)
            {
               if(this.m_inactiveUserActions[queueX].name == popupName)
               {
                  addToQueue = false;
                  break;
               }
            }
         }
         if(addToQueue)
         {
            if(showFirst)
            {
               this.m_inactiveUserActions.unshift(popup);
            }
            else
            {
               this.m_inactiveUserActions.push(popup);
            }
         }
      }
      
      public function addInactiveUserCallback(callback:Function) : void
      {
         if(null == this.m_inactiveUserActions)
         {
            this.m_inactiveUserActions = new Array();
         }
         this.m_inactiveUserActions.push(callback);
      }
      
      protected function processInactiveUserActions() : void
      {
         var i:int = 0;
         if(null != this.m_inactiveUserActions)
         {
            for(i = 0; i < this.m_inactiveUserActions.length; i++)
            {
               if(this.m_inactiveUserActions[i] is DisplayObject)
               {
                  UI.displayPopup(this.m_inactiveUserActions[i] as DisplayObject);
               }
               else if(this.m_inactiveUserActions[i] is Function)
               {
                  (this.m_inactiveUserActions[i] as Function)();
               }
            }
            this.m_inactiveUserActions = null;
         }
      }
   }
}

