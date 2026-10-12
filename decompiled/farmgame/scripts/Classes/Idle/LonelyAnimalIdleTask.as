package Classes.Idle
{
   import Classes.Constants.Experiments;
   import Classes.LonelyAnimal;
   import Classes.util.FarmGameUtil;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.ToasterManager;
   import Transactions.TCreateLonelyCow;
   import Widgets.Windows.LonelyAnimal.LonelyAnimalToasterWindow;
   import flash.display.DisplayObject;
   
   public class LonelyAnimalIdleTask extends BaseIdleTask
   {
      
      public static const LONELY_ANIMAL_IDLE_TASK:String = "lonely_animal_idle_task";
      
      protected static var m_lonelyAnimalServerInterval:Number = 0;
      
      public static var shouldShow:Boolean = true;
      
      private static var m_lonelyAnimalMapResource:LonelyAnimal = null;
      
      protected var m_sessionDelay:Number = 60000;
      
      protected var m_timeToPop:Number = 0;
      
      private var m_lonelyAnimalDialog:GenericIconPopup;
      
      public function LonelyAnimalIdleTask(params:Object = null)
      {
         var giftMissionTimeRange:int = 0;
         var giftRange:int = 0;
         super();
         m_displaysPopup = true;
         if(Boolean(params) && params.hasOwnProperty("serverInterval"))
         {
            LonelyAnimalIdleTask.lonelyAnimalServerInterval = params["serverInterval"];
         }
         var levelRequirement:Boolean = Global.player.level >= Global.farmGameSettingsManager.getAttribute("lonelyAnimalStartLevel",5);
         if(!Global.player.getSeenSessionFlag(LONELY_ANIMAL_IDLE_TASK) && levelRequirement)
         {
            m_lonelyAnimalMapResource = LonelyAnimal.getLonelyAnimalInstance();
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_LONELY_ANIMAL_CREW) > 0 && levelRequirement)
         {
            this.m_timeToPop = FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         else
         {
            giftMissionTimeRange = Global.farmGameSettingsManager.getNumber("giftMissionTimeRange");
            giftRange = Math.round(Math.random() * giftMissionTimeRange);
            this.m_sessionDelay = (Global.farmGameSettingsManager.getNumber("giftMissionTime") + giftRange) * 1000;
            this.m_timeToPop = Math.max(this.m_sessionDelay,m_lonelyAnimalServerInterval);
         }
      }
      
      public static function get lonelyAnimalServerInterval() : Number
      {
         return m_lonelyAnimalServerInterval;
      }
      
      public static function set lonelyAnimalServerInterval(num:Number) : void
      {
         m_lonelyAnimalServerInterval = num;
      }
      
      public static function conditionallyRedrawLonelyAnimal() : void
      {
         if(m_lonelyAnimalMapResource != null)
         {
            LonelyAnimal.resetSeenFlag();
            m_lonelyAnimalMapResource = LonelyAnimal.getLonelyAnimalInstance();
         }
      }
      
      override public function get shouldAdd() : Boolean
      {
         var levelRequirement:Boolean = false;
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         var result:Boolean = false;
         if(m_lonelyAnimalMapResource != null)
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_LONELY_ANIMAL_CREW) > 0)
            {
               levelRequirement = Global.player.level >= Global.farmGameSettingsManager.getAttribute("lonelyAnimalStartLevel",5);
               result = levelRequirement;
            }
            else
            {
               result = shouldShow && m_lonelyAnimalServerInterval > 0;
            }
         }
         return result;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         var lonelyAnimalCanFire:Boolean = true;
         var levelRequirement:Boolean = Global.player.level >= Global.farmGameSettingsManager.getAttribute("lonelyAnimalStartLevel",5);
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_LONELY_ANIMAL_CREW) > 0 && levelRequirement)
         {
            lonelyAnimalCanFire = m_lonelyAnimalMapResource.ready;
         }
         if(Global.worldManager.isInStaticWorld())
         {
            lonelyAnimalCanFire = false;
         }
         return GlobalEngine.currentTime > this.m_timeToPop && lonelyAnimalCanFire;
      }
      
      override public function fire() : void
      {
         var lonelyCowObj:DisplayObject = null;
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_LONELY_ANIMAL_CREW) > 0)
         {
            if(!Global.player.getSeenSessionFlag(LonelyAnimal.LONELY_ANIMAL_SEEN_FLAG) && m_lonelyAnimalMapResource != null)
            {
               Global.player.setSeenSessionFlag(LonelyAnimal.LONELY_ANIMAL_SEEN_FLAG);
               ToasterManager.getInstance().add(new LonelyAnimalToasterWindow(m_lonelyAnimalMapResource));
            }
         }
         else
         {
            lonelyCowObj = Global.stage.getChildByName("lonelyCowPopup");
            if(lonelyCowObj == null)
            {
               TransactionManager.addTransaction(new TCreateLonelyCow());
            }
            m_lonelyAnimalServerInterval = GlobalEngine.currentTime + this.m_sessionDelay;
            IdleTaskQueue.getInstance().addTask(new LonelyAnimalIdleTask());
         }
      }
      
      private function onHelpClick(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            Global.world.centerOnObject(m_lonelyAnimalMapResource,2,10);
         }
         this.m_lonelyAnimalDialog.close();
      }
   }
}

