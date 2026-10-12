package Classes.buffs
{
   import Classes.Buff;
   import Classes.ItemRequirement;
   import Classes.ZItem.BuffItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.LicenseManager;
   
   public class BBushel extends Buff
   {
      
      public static const TYPE_LICENSE:int = 0;
      
      public static const TYPE_MASTERY:int = 1;
      
      public static const TYPE_CROPEXP:int = 2;
      
      public function BBushel(itemName:String)
      {
         super(itemName);
      }
      
      public static function getBuffDuration() : Number
      {
         var bushelItem:BuffItem = Global.farmGameSettingsManager.getFarmItemByName("BBushel") as BuffItem;
         return bushelItem.buffExpires;
      }
      
      public static function getBushelBuff(seed:String) : int
      {
         var buffName:String = null;
         var result:int = -1;
         for(buffName in Global.player.buffs)
         {
            if(buffName.indexOf("Bushel") >= 0)
            {
               if(Global.player.buffs[buffName].crop == seed)
               {
                  result = int(Global.player.buffs[buffName].type);
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getEligibleBushelBuffType(seedCode:String) : int
      {
         var type:int = 0;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(seedCode);
         var requirementNeeded:ItemRequirement = item.firstMissingRequirement;
         var hasUnlockLicense:Boolean = LicenseManager.getInstance().hasCurrentLicense(seedCode);
         var grantsLicense:Boolean = item.bushelGrantsLicense;
         if(grantsLicense && (Global.player.level < item.requiredLevel || requirementNeeded != null || hasUnlockLicense))
         {
            type = TYPE_LICENSE;
         }
         else if(Global.player.checkMastery(seedCode))
         {
            type = TYPE_CROPEXP;
         }
         else
         {
            type = TYPE_MASTERY;
         }
         return type;
      }
      
      override public function unapply() : void
      {
         var buff:BBushel = null;
         var buffStats:Object = Global.player.buffs[m_itemName];
         switch(buffStats.type)
         {
            case TYPE_LICENSE:
               buff = new BLicense(m_itemName);
               break;
            case TYPE_MASTERY:
               buff = new BMastery(m_itemName);
               break;
            case TYPE_CROPEXP:
               buff = new BCropExp(m_itemName);
         }
         if(buff)
         {
            buff.unapply();
         }
         Global.hud.cropBoostIcon.hideBuffDetails();
         super.unapply();
      }
      
      override public function tick() : void
      {
         this.updateToolTip();
      }
      
      public function get seedFriendlyName() : String
      {
         var seedCode:String = Global.player.buffs[m_itemName].crop;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(seedCode);
         return item.friendlyName;
      }
      
      public function get iconUrl() : String
      {
         var seedCode:String = Global.player.buffs[m_itemName].crop;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(seedCode);
         return item.icon;
      }
      
      public function get buffType() : int
      {
         return Global.player.buffs[m_itemName].type;
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var seedCode:String = Global.player.buffs[m_itemName].crop;
         var type:int = BBushel.getEligibleBushelBuffType(seedCode);
         var curTime:int = int(Global.player.buffs[m_itemName].time);
         Global.player.buffs[m_itemName] = {
            "type":type,
            "time":curTime,
            "crop":seedCode
         };
         var buff:BBushel = this.getBushelBuff();
         if(buff)
         {
            buff.apply(isNew);
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(seedCode);
         this.updateToolTip();
      }
      
      protected function updateToolTip() : void
      {
         var expireString:String = null;
         var timeRemaining:Array = this.friendlyTimeRemainingZLoc;
         if(timeRemaining["Days"] > 0 && timeRemaining["Hours"] > 0)
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeDaysHours",{
               "dayNum":timeRemaining["Days"],
               "hourNum":timeRemaining["Hours"]
            });
         }
         else if(timeRemaining["Days"] > 0)
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeDays",{"dayNum":timeRemaining["Days"]});
         }
         else if(timeRemaining["Hours"] > 0 && timeRemaining["Minutes"] > 0)
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeHoursMins",{
               "hourNum":timeRemaining["Hours"],
               "minuteNum":timeRemaining["Minutes"]
            });
         }
         else if(timeRemaining["Hours"] > 0)
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeHours",{"hourNum":timeRemaining["Hours"]});
         }
         else if(timeRemaining["Minutes"] > 0 && timeRemaining["Seconds"] > 0)
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeMinsSecs",{
               "minuteNum":timeRemaining["Minutes"],
               "secondNum":timeRemaining["Seconds"]
            });
         }
         else if(timeRemaining["Minutes"] > 0)
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeMins",{"minuteNum":timeRemaining["Minutes"]});
         }
         else
         {
            expireString = ZLocUtils.t("Crafting","Expires_FriendlyTimeSecs",{"secondNum":timeRemaining["Seconds"]});
         }
         var cropBoostBuffStr:String = ZLocUtils.t("Crafting","CropBuff_Type" + this.buffType,{
            "seedName":ZLocUtils.tk_pk(this.seedFriendlyName),
            "seed_same":ZLocUtils.tk_pk(this.seedFriendlyName),
            "expiresStr":expireString
         });
         Global.hud.cropBoostIcon.setBuffDetails(this.iconUrl,this.buffType,cropBoostBuffStr);
      }
      
      public function get friendlyTimeRemaining() : String
      {
         var timeAdded:Number = this.getAddedTime();
         var serverTime:Number = GlobalEngine.serverTime / 1000;
         var timeElapsed:Number = serverTime - timeAdded;
         return FarmGameUtil.toFriendlyTime(this.getExpiresTTL() - timeElapsed);
      }
      
      public function get friendlyTimeRemainingZLoc() : Array
      {
         var timeAdded:Number = this.getAddedTime();
         var serverTime:Number = GlobalEngine.serverTime / 1000;
         var timeElapsed:Number = serverTime - timeAdded;
         return FarmGameUtil.toFriendlyTimeZLoc(this.getExpiresTTL() - timeElapsed);
      }
      
      private function getBushelBuff() : BBushel
      {
         var buff:BBushel = null;
         var buffStats:Object = Global.player.buffs[m_itemName];
         switch(buffStats.type)
         {
            case TYPE_LICENSE:
               buff = new BLicense(m_itemName);
               break;
            case TYPE_MASTERY:
               buff = new BMastery(m_itemName);
               break;
            case TYPE_CROPEXP:
               buff = new BCropExp(m_itemName);
         }
         return buff;
      }
   }
}

