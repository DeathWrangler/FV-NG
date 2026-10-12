package Classes.buffs
{
   import Classes.BushelReportActionDropHandler;
   import Classes.PermanentBuff;
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   
   public class BPermanentTypeGain extends PermanentBuff
   {
      
      public static const SUBTYPE_XP:String = "xp_gain";
      
      public static const SUBTYPE_SUFIX:String = "_gain";
      
      public static const SUBTYPE_COIN:String = "coin_gain";
      
      private static const ADDITIONAL_DOUBLE_STATUE_MULTIPLIER:int = 2;
      
      public function BPermanentTypeGain(itemName:String)
      {
         super(itemName);
      }
      
      public static function getCurrentGainBonus(subtype:String) : int
      {
         var multiplierKey:String = null;
         var buff:FarmItem = null;
         var result:int = 1;
         var permanentGainBuffs:Array = Global.player.getBuffItemsByClass(BPermanentTypeGain,subtype);
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         for each(buff in permanentGainBuffs)
         {
            if(isInDataSourceExperiment)
            {
               multiplierKey = buff.getStringFromDataSource("multiplierKey");
            }
            else
            {
               multiplierKey = buff.xml.multiplierKey;
            }
            result *= Global.farmGameSettingsManager.getInt(multiplierKey,1);
         }
         return result;
      }
      
      public static function getNewDoubleBushelBonus() : int
      {
         var result:int = int(BPermanentTypeGain.getCurrentGainBonus("bushel_gain"));
         if(BushelReportActionDropHandler.canPlayerSeeFeature() && result > 1)
         {
            result *= ADDITIONAL_DOUBLE_STATUE_MULTIPLIER;
         }
         return result;
      }
   }
}

