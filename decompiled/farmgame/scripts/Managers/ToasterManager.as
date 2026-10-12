package Managers
{
   import Classes.Constants.Experiments;
   import Widgets.Windows.ToasterWindow;
   import flash.events.Event;
   
   public class ToasterManager
   {
      
      public static const DISPLAYED_EVENT:String = "displayed";
      
      private static var m_instance:ToasterManager = null;
      
      private static var m_allowInstantiation:Boolean = false;
      
      private static var m_isPostPurchaseFlowExperimentOn:Boolean = false;
      
      private var m_toasterQueue:Vector.<ToasterWindow> = new Vector.<ToasterWindow>();
      
      private var m_currentToaster:ToasterWindow = null;
      
      private var m_queuePaused:Boolean = false;
      
      private var m_toasterHeight:Number = NaN;
      
      private var m_nonPausableCounter:int = 0;
      
      public function ToasterManager()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : ToasterManager
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new ToasterManager();
            m_allowInstantiation = false;
            m_isPostPurchaseFlowExperimentOn = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
         }
         return m_instance;
      }
      
      public function togglePauseQueue(value:Boolean) : void
      {
         this.m_queuePaused = value;
      }
      
      public function isQueuePaused() : Boolean
      {
         return this.m_queuePaused;
      }
      
      public function add(toaster:ToasterWindow) : void
      {
         if(!Global.suppressAllToasters && Global.nopopupManager.canDisplayPopup(toaster))
         {
            if(this.canDisplayImmediately())
            {
               this.display(toaster);
            }
            else
            {
               this.defer(toaster);
               if(m_isPostPurchaseFlowExperimentOn && !toaster.isPauseable)
               {
                  this.displayNext();
               }
            }
         }
      }
      
      public function remove(toaster:ToasterWindow) : void
      {
         var index:int = 0;
         if(toaster)
         {
            if(this.m_currentToaster == toaster)
            {
               this.closeCurrentToaster();
            }
            index = this.m_toasterQueue.indexOf(toaster);
            if(index >= 0)
            {
               this.removeFromToasterQueueAt(index);
               toaster.close();
            }
         }
      }
      
      public function isToasterBeingDisplayed() : Boolean
      {
         return this.m_currentToaster != null;
      }
      
      public function addImmediate(toaster:ToasterWindow) : void
      {
         if(this.m_currentToaster)
         {
            this.m_currentToaster.removeEventListener(Event.CLOSE,this.onToasterClose);
            this.m_currentToaster.close();
         }
         this.display(toaster);
      }
      
      private function canDisplayImmediately() : Boolean
      {
         return this.m_currentToaster == null && this.m_toasterQueue.length == 0 && !this.m_queuePaused;
      }
      
      public function closeCurrentToaster() : void
      {
         if(this.m_currentToaster != null && this.m_currentToaster.allowToasterManangerToClose)
         {
            this.m_currentToaster.close();
         }
      }
      
      private function display(toaster:ToasterWindow) : void
      {
         if(!this.m_queuePaused)
         {
            this.displayHelper(toaster);
         }
         else if(m_isPostPurchaseFlowExperimentOn)
         {
            if(toaster.isPauseable)
            {
               this.defer(toaster);
               if(this.m_nonPausableCounter > 0 && !this.m_currentToaster)
               {
                  this.displayNext();
               }
            }
            else if(this.m_currentToaster)
            {
               this.defer(toaster);
            }
            else
            {
               this.displayHelper(toaster);
            }
         }
         else
         {
            this.defer(toaster);
         }
      }
      
      private function displayHelper(toaster:ToasterWindow) : void
      {
         this.m_currentToaster = toaster;
         if(!isNaN(this.m_toasterHeight) && m_isPostPurchaseFlowExperimentOn)
         {
            this.m_currentToaster.setToasterOffsetY(this.m_toasterHeight);
         }
         Global.ui.displayToasterPopup(this.m_currentToaster);
         this.m_currentToaster.addEventListener(Event.CLOSE,this.onToasterClose);
         this.m_currentToaster.dispatchEvent(new Event(ToasterManager.DISPLAYED_EVENT));
      }
      
      private function onToasterClose(event:Event) : void
      {
         if(this.m_currentToaster != null)
         {
            this.m_currentToaster.removeEventListener(Event.CLOSE,this.onToasterClose);
            this.m_currentToaster = null;
         }
         this.displayNext();
      }
      
      private function displayNext() : void
      {
         var toaster:ToasterWindow = null;
         if(this.m_toasterQueue.length > 0 && this.m_currentToaster == null)
         {
            toaster = this.popFirstOfToasterQueue();
            this.display(toaster);
         }
      }
      
      public function togglePause(value:Boolean) : void
      {
         this.m_queuePaused = value;
         if(this.m_queuePaused)
         {
            if(!m_isPostPurchaseFlowExperimentOn || Boolean(this.m_currentToaster) && Boolean(this.m_currentToaster.isPauseable))
            {
               this.closeCurrentToaster();
            }
         }
         else
         {
            this.displayNext();
         }
      }
      
      private function defer(toaster:ToasterWindow) : void
      {
         this.pushToToasterQueue(toaster);
      }
      
      public function set toasterHeight(newToasterHeight:Number) : void
      {
         this.m_toasterHeight = newToasterHeight;
      }
      
      private function pushToToasterQueue(toaster:ToasterWindow) : void
      {
         this.m_toasterQueue.push(toaster);
         if(!toaster.isPauseable && m_isPostPurchaseFlowExperimentOn)
         {
            ++this.m_nonPausableCounter;
         }
      }
      
      private function popFirstOfToasterQueue() : ToasterWindow
      {
         var toaster:ToasterWindow = this.m_toasterQueue.shift();
         if(!toaster.isPauseable && m_isPostPurchaseFlowExperimentOn)
         {
            --this.m_nonPausableCounter;
         }
         return toaster;
      }
      
      private function removeFromToasterQueueAt(index:int) : void
      {
         var toaster:ToasterWindow = this.m_toasterQueue[index];
         if(!toaster.isPauseable && m_isPostPurchaseFlowExperimentOn)
         {
            --this.m_nonPausableCounter;
         }
         this.m_toasterQueue.splice(index,1);
      }
   }
}

