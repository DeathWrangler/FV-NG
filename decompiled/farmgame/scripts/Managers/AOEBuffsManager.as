package Managers
{
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import flash.utils.Dictionary;
   
   public class AOEBuffsManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "aoeBuffs";
      
      private const OPTION_ACTIVEBUFFS:String = "activeBuffs";
      
      private const BUFF_KEY_TS:String = "appliedTS";
      
      private const BUFF_KEY_ITEMCODE:String = "itemCode";
      
      private var m_sourceBuffMapping:Dictionary;
      
      public function AOEBuffsManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      public static function getInstance(featureName:String = "aoeBuffs") : AOEBuffsManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,AOEBuffsManager) as AOEBuffsManager;
      }
      
      public function getActiveBuffForSourceID(sourceID:String) : String
      {
         var buffs:Object = null;
         var buffTimeLeft:Number = NaN;
         var result:String = null;
         if(sourceID)
         {
            buffs = this.getAppliedBuffs();
            if(Boolean(buffs) && Boolean(buffs[sourceID]))
            {
               buffTimeLeft = this.getBuffTimeLeft(buffs[sourceID]);
               if(buffTimeLeft > 0)
               {
                  result = buffs[sourceID][this.BUFF_KEY_ITEMCODE];
               }
            }
         }
         return result;
      }
      
      private function getBuffTimeLeft(buffObj:Object) : Number
      {
         var buffItem:ConsumableItem = null;
         var result:Number = 0;
         if(buffObj)
         {
            buffItem = Global.farmGameSettingsManager.getFarmItemByCode(buffObj[this.BUFF_KEY_ITEMCODE]) as ConsumableItem;
            if(buffItem)
            {
               result = buffItem.buffExpires - this.getBuffAge(buffObj);
            }
         }
         return result;
      }
      
      private function getBuffAge(buffObj:Object) : Number
      {
         var timestamp:Number = NaN;
         var result:Number = -1;
         if(Boolean(buffObj) && Boolean(buffObj[this.BUFF_KEY_TS]))
         {
            timestamp = buffObj[this.BUFF_KEY_TS] * 1000;
            result = FarmGameUtil.getTimeDelta(timestamp,FarmGameUtil.SECONDS);
         }
         return result;
      }
      
      public function getTimeLeftForActiveBuff(sourceItemCode:String) : Number
      {
         var buffs:Object = null;
         var result:Number = 0;
         if(this.getActiveBuffForSourceID(sourceItemCode))
         {
            buffs = this.getAppliedBuffs();
            if(buffs[sourceItemCode])
            {
               result = this.getBuffTimeLeft(buffs[sourceItemCode]);
            }
         }
         return result;
      }
      
      public function setActiveBuffForSourceID(buffItemCode:String, sourceID:String) : void
      {
         if(Boolean(buffItemCode && buffItemCode != "") && Boolean(sourceID) && sourceID != "")
         {
            if(this.isValidSource(sourceID))
            {
               if(this.isValidBuffForSourceID(buffItemCode,sourceID))
               {
                  if(this.getBuffCount(buffItemCode) > 0)
                  {
                     if(!this.getActiveBuffForSourceID(sourceID))
                     {
                        if(this.applyBuffForSourceID(buffItemCode,sourceID))
                        {
                           this.deductBuff(buffItemCode);
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function getBonusesForBuff(buffCode:String) : Dictionary
      {
         var bushelMultiplier:Number = NaN;
         var masteryBonus:Number = NaN;
         var plantTimeRatio:Number = NaN;
         var result:Dictionary = new Dictionary();
         result[AOEManager.BONUS_TYPE_MULT] = new Dictionary();
         result[AOEManager.BONUS_TYPE_ADD] = new Dictionary();
         var buffItem:ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(buffCode) as ConsumableItem;
         if(buffItem)
         {
            bushelMultiplier = buffItem.bushelMultiplier;
            if(bushelMultiplier > 1)
            {
               result[AOEManager.BONUS_TYPE_MULT][AOEManager.HARVEST_YIELD_BONUS_KEY] = bushelMultiplier;
            }
            masteryBonus = buffItem.masteryBonus;
            if(masteryBonus > 1)
            {
               result[AOEManager.BONUS_TYPE_MULT][AOEManager.MASTERY_BONUS_KEY] = masteryBonus;
            }
            plantTimeRatio = buffItem.plantTimeRatio;
            if(plantTimeRatio < 1)
            {
               result[AOEManager.BONUS_TYPE_ADD][AOEManager.HARVEST_YIELD_BONUS_KEY] = 1 / plantTimeRatio;
            }
         }
         return result;
      }
      
      private function applyBuffForSourceID(buffItemCode:String, sourceID:String) : Boolean
      {
         var result:Boolean = false;
         var appliedBuffs:Object = this.getAppliedBuffs();
         if(!appliedBuffs)
         {
            appliedBuffs = {};
         }
         if(appliedBuffs)
         {
            if(!appliedBuffs[sourceID])
            {
               appliedBuffs[sourceID] = {};
            }
            appliedBuffs[sourceID][this.BUFF_KEY_TS] = GlobalEngine.serverTime / 1000;
            appliedBuffs[sourceID][this.BUFF_KEY_ITEMCODE] = buffItemCode;
            this.setAppliedBuffs(appliedBuffs);
            result = true;
         }
         return result;
      }
      
      private function deductBuff(buffItemCode:String) : Boolean
      {
         return JMInnovationManager.getInstance().deductBuff(buffItemCode);
      }
      
      private function isValidSource(sourceID:String) : Boolean
      {
         var result:Boolean = false;
         var sourceBuffMap:Dictionary = this.getSourceBuffMapping();
         if(sourceBuffMap)
         {
            if(sourceBuffMap[sourceID])
            {
               result = true;
            }
         }
         return result;
      }
      
      private function getSourceBuffMapping() : Dictionary
      {
         var buffDict:Dictionary = null;
         var buffItem:FarmItem = null;
         var sourceID:String = null;
         var sourceItem:FarmItem = null;
         var buffXML:XML = null;
         if(m_featureConfig)
         {
            if(!this.m_sourceBuffMapping)
            {
               this.m_sourceBuffMapping = new Dictionary();
               buffDict = new Dictionary();
               for each(buffXML in m_featureConfig.buffs.item)
               {
                  buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffXML.@name.toString());
                  if(buffItem)
                  {
                     sourceID = buffXML.@sourceItemCode.toString();
                     if(sourceID)
                     {
                        sourceItem = Global.farmGameSettingsManager.getFarmItemByCode(sourceID);
                        if(sourceItem)
                        {
                           if(!buffDict[sourceID])
                           {
                              buffDict[sourceID] = new Dictionary();
                           }
                           buffDict[sourceID][buffItem.code] = 1;
                        }
                     }
                  }
                  this.m_sourceBuffMapping = buffDict;
               }
            }
         }
         return this.m_sourceBuffMapping;
      }
      
      private function isValidBuffForSourceID(buffItemCode:String, sourceID:String) : Boolean
      {
         var result:Boolean = false;
         var sourceBuffMapping:Dictionary = this.getSourceBuffMapping();
         if(Boolean(sourceBuffMapping) && Boolean(sourceBuffMapping[sourceID]) && Boolean(sourceBuffMapping[sourceID][buffItemCode]))
         {
            result = true;
         }
         return result;
      }
      
      private function getBuffCount(buffItemCode:String) : Number
      {
         return JMInnovationManager.getInstance().getBuffCountByCode(buffItemCode);
      }
      
      private function getAppliedBuffs() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,this.OPTION_ACTIVEBUFFS);
      }
      
      private function setAppliedBuffs(buffs:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,this.OPTION_ACTIVEBUFFS,buffs);
      }
   }
}

