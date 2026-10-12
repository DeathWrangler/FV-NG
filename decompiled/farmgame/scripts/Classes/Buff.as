package Classes
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   import flash.utils.getQualifiedClassName;
   
   public class Buff
   {
      
      protected var m_itemName:String;
      
      public function Buff(itemName:String)
      {
         super();
         this.m_itemName = itemName;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function tick() : void
      {
      }
      
      public function apply(isNew:Boolean = false) : void
      {
         if(!Global.player.buffs[this.itemName])
         {
            Global.player.buffs[this.itemName] = {"time":GlobalEngine.serverTime / 1000};
         }
         else if(isNew == true)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_ANIMAL) > 1 || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_TREE) > 1 || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_CRAFT) > 1)
            {
               Global.player.buffs[this.itemName].time += this.getDurationAdded();
            }
            else
            {
               Global.player.buffs[this.itemName].time += this.getExpiresTTL();
            }
         }
         var buffItem:FarmItem = this.getItem();
         if(buffItem != null && buffItem.limit > 0)
         {
            Global.player.incrementActionCount(buffItem.name,false);
         }
      }
      
      public function unapply() : void
      {
         delete Global.player.buffs[this.itemName];
      }
      
      public function getItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByName(this.itemName);
      }
      
      public function getDurationAdded() : Number
      {
         var retVal:Number = NaN;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            retVal = item.getNumberFromDataSource("buffExpires");
         }
         else
         {
            retVal = Number(item.xml.buffExpires);
         }
         return retVal;
      }
      
      protected function getExpiresTTL() : Number
      {
         var retVal:Number = NaN;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            retVal = this.getItem().getNumberFromDataSource("buffExpires");
         }
         else
         {
            retVal = Number(this.getItem().xml.buffExpires);
         }
         return retVal;
      }
      
      protected function getAddedTime() : Number
      {
         var retVal:int = 0;
         if(Global.player.buffs[this.itemName])
         {
            retVal = Global.player.buffs[this.itemName].time as Number;
         }
         return retVal;
      }
      
      public function getClassName() : String
      {
         var classParts:Array = getQualifiedClassName(this).split("::");
         return classParts[classParts.length - 1];
      }
      
      public function isExpired() : Boolean
      {
         var timeElapsed:Number = NaN;
         var result:Boolean = false;
         if(Global.player.hasBuffApplied(this))
         {
            timeElapsed = GlobalEngine.serverTime / 1000 - this.getAddedTime();
            if(timeElapsed > this.getExpiresTTL())
            {
               result = true;
            }
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      public function get secondsRemaining() : int
      {
         var timeElapsed:Number = GlobalEngine.serverTime / 1000 - this.getAddedTime();
         return this.getExpiresTTL() - timeElapsed;
      }
      
      public function get expirationTime() : int
      {
         return this.getAddedTime() + this.getExpiresTTL();
      }
      
      public function hasExceededUseLimit() : Boolean
      {
         var result:Boolean = false;
         var buffItem:FarmItem = this.getItem();
         var numPlayerUses:int = Global.player.getActionCount(buffItem.name);
         var useLimit:int = buffItem.limit;
         if(useLimit > 0 && numPlayerUses >= useLimit)
         {
            result = true;
         }
         return result;
      }
   }
}

