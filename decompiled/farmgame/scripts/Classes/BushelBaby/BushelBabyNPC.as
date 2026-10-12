package Classes.BushelBaby
{
   public class BushelBabyNPC
   {
      
      public static const UNLOCK_PROPERTY:String = "unlocked";
      
      public static const COMPLETE_PROPERTY:String = "complete";
      
      public static const LEVEL_PROPERTY:String = "currentLevel";
      
      private var m_system:BushelBabySystem;
      
      private var m_name:String;
      
      private var m_unlockCost:int;
      
      private var m_friendlyTitle:String;
      
      private var m_levels:Vector.<BushelBabyNPCLevel>;
      
      public function BushelBabyNPC(system:BushelBabySystem, name:String, levels:Array)
      {
         var levelObj:Object = null;
         super();
         this.m_system = system;
         this.m_name = name;
         this.m_unlockCost = levels[0].unlockCost;
         this.m_levels = new Vector.<BushelBabyNPCLevel>();
         for each(levelObj in levels)
         {
            this.m_levels.push(new BushelBabyNPCLevel(this,levelObj));
         }
         this.m_friendlyTitle = this.m_levels[this.m_levels.length - 1].friendlyItemTitle;
      }
      
      public function get system() : BushelBabySystem
      {
         return this.m_system;
      }
      
      public function get friendlyTitle() : String
      {
         return this.m_friendlyTitle;
      }
      
      public function get levels() : Vector.<BushelBabyNPCLevel>
      {
         return this.m_levels;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get unlockCost() : int
      {
         return this.m_unlockCost;
      }
      
      public function get levelsUntilCompletion() : int
      {
         return this.totalLevels - this.m_system.getNPCData(this.m_name)[LEVEL_PROPERTY];
      }
      
      public function get complete() : Boolean
      {
         var result:Boolean = false;
         if(this.m_system.getNPCData(this.m_name)[LEVEL_PROPERTY] == this.totalLevels)
         {
            result = true;
         }
         return result;
      }
      
      public function hasCompletedBefore() : Boolean
      {
         var result:Boolean = false;
         if(this.m_system.getNPCData(this.m_name)[COMPLETE_PROPERTY] >= 1)
         {
            result = true;
         }
         return result;
      }
      
      public function get unlocked() : Boolean
      {
         return this.m_unlockCost <= 0 || Boolean(this.m_system.getNPCData(this.m_name)[UNLOCK_PROPERTY]);
      }
      
      public function get currentLevelNum() : int
      {
         return this.m_system.getNPCData(this.m_name)[LEVEL_PROPERTY] = this.m_system.getNPCData(this.m_name)[LEVEL_PROPERTY] || 0;
      }
      
      public function buyUnlock() : Boolean
      {
         var cost:int = 0;
         var result:Boolean = false;
         if(!this.unlocked)
         {
            cost = this.unlockCost;
            if(cost > 0 && Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               this.setUnlocked();
               result = true;
            }
         }
         return result;
      }
      
      public function get animalName() : String
      {
         return this.levels[this.levels.length - 1].item.name;
      }
      
      public function resetLevel() : void
      {
         this.m_system.setNPCData(this.m_name,LEVEL_PROPERTY,0);
         this.m_system.refreshCurrentWindow();
      }
      
      public function setUnlocked(makeTransaction:Boolean = true) : void
      {
         this.m_system.setNPCData(this.m_name,UNLOCK_PROPERTY,true,makeTransaction);
         this.m_system.refreshCurrentWindow();
      }
      
      public function incrementComplete() : void
      {
         this.m_system.incrementComplete(this.m_name);
      }
      
      public function get canUnlock() : Boolean
      {
         var index:int = 0;
         var result:Boolean = false;
         if(this.m_unlockCost >= 0 && !this.unlocked)
         {
            index = this.m_system.npcs.indexOf(this);
            if(index <= 0)
            {
               result = false;
            }
            else
            {
               result = this.m_system.npcs[index - 1].unlocked;
            }
         }
         return result;
      }
      
      public function get totalLevels() : int
      {
         return this.m_levels.length;
      }
      
      public function getCurrentLevel() : BushelBabyNPCLevel
      {
         var result:BushelBabyNPCLevel = null;
         if(this.m_levels)
         {
            result = this.m_levels[Math.min(this.currentLevelNum,this.m_levels.length - 1)] as BushelBabyNPCLevel;
         }
         return result;
      }
      
      public function upgradeLevel(makeTransaction:Boolean = true) : void
      {
         if(this.currentLevelNum < this.totalLevels)
         {
            this.m_system.setNPCData(this.m_name,LEVEL_PROPERTY,this.currentLevelNum + 1,makeTransaction);
            this.m_system.refreshCurrentWindow();
         }
      }
      
      public function setLevel(level:int, makeTransaction:Boolean = true) : void
      {
         if(this.currentLevelNum < this.totalLevels)
         {
            this.m_system.setNPCData(this.m_name,LEVEL_PROPERTY,level,makeTransaction);
            this.m_system.refreshCurrentWindow();
         }
      }
   }
}

