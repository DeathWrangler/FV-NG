package Classes.buffs
{
   import Classes.Buff;
   import Classes.Constants.Experiments;
   import Classes.ZItem.BuffItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.TimedBuffRebuyWindow;
   
   public class BMasteryTimed extends Buff
   {
      
      public static const CRAFTING_ITEM_NAME:String = "buff_double_crafting_mastery_1day_v2";
      
      public static const ANIMAL_ITEM_NAME:String = "buff_double_animal_mastery_1day_v2";
      
      public static const TREE_ITEM_NAME:String = "buff_double_tree_mastery_1day_v2";
      
      public static const TREE_PERMA_BUFF_NAME:String = "buff_permanent_mastery_crops_trees";
      
      public static const CRAFTING_PERMA_BUFF_NAME:String = "buff_permanent_mastery_craft";
      
      public static const ANIMAL_PERMA_BUFF_NAME:String = "buff_permanent_mastery_animal";
      
      public static const SUBTYPE_STRING:String = "subtype";
      
      public static const DURATION_STRING:String = "duration";
      
      public static const ANIMAL_TYPE:String = "animal";
      
      public static const CRAFTING_TYPE:String = "crafting";
      
      public static const TREE_TYPE:String = "tree";
      
      public static const SEED_TYPE:String = "seed";
      
      private static const TOASTER_ASSET_PATH:String = "assets/dialogs/FV_timeconsumable_BannerAd.swf";
      
      public function BMasteryTimed(itemName:String)
      {
         super(itemName);
      }
      
      public static function getPermanemtBuffNameFromType(itemType:String) : String
      {
         var result:String = null;
         switch(itemType)
         {
            case BMasteryTimed.ANIMAL_TYPE:
               result = BMasteryTimed.ANIMAL_PERMA_BUFF_NAME;
               break;
            case BMasteryTimed.CRAFTING_TYPE:
               result = BMasteryTimed.CRAFTING_PERMA_BUFF_NAME;
               break;
            case BMasteryTimed.TREE_TYPE:
            case BMasteryTimed.SEED_TYPE:
               result = BMasteryTimed.TREE_PERMA_BUFF_NAME;
         }
         return result;
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var buffDuration:int = 0;
         var itemXml:XML = null;
         var buffDays:int = 0;
         var masteryTypeText:String = null;
         var toasterAsset:String = null;
         super.apply(isNew);
         if(isNew && Boolean(Global.player.buffs[this.itemName]))
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               buffDuration = (Global.farmGameSettingsManager.getFarmItemByName(m_itemName) as BuffItem).buffExpires;
            }
            else
            {
               itemXml = Global.farmGameSettingsManager.getItemXMLByName(m_itemName);
               buffDuration = int(itemXml.child("buffExpires"));
            }
            if(!Global.player.buffs[this.itemName].hasOwnProperty(DURATION_STRING))
            {
               Global.player.buffs[this.itemName].duration = buffDuration;
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_SURFACE) > 0)
            {
               buffDays = buffDuration / FarmGameUtil.NUM_SECS_IN_DAY;
               masteryTypeText = null;
               toasterAsset = TOASTER_ASSET_PATH;
               switch(this.itemName)
               {
                  case BMasteryTimed.ANIMAL_ITEM_NAME:
                     masteryTypeText = "Animal";
                     break;
                  case BMasteryTimed.CRAFTING_ITEM_NAME:
                     masteryTypeText = "Crafting";
                     break;
                  case BMasteryTimed.TREE_ITEM_NAME:
                     masteryTypeText = "Crop / Tree";
               }
               ToasterManager.getInstance().addImmediate(new IconTitleToasterWindow(ZLocUtils.t("Dialogs","TimedConsumablesToasterHeader"),ZLocUtils.t("Dialogs","TimedConsumablesToasterText",{
                  "type":masteryTypeText,
                  "number":buffDays
               }),null,toasterAsset));
            }
         }
      }
      
      override protected function getExpiresTTL() : Number
      {
         var result:int = 0;
         if(Boolean(Global.player.buffs[this.itemName]) && Boolean(Global.player.buffs[this.itemName].hasOwnProperty(DURATION_STRING)))
         {
            result = int(Global.player.buffs[this.itemName].duration);
         }
         else
         {
            result = super.getExpiresTTL();
         }
         return result;
      }
      
      override public function unapply() : void
      {
         super.unapply();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TIMED_CONSUMABLE_SURFACE) > 0)
         {
            UI.displayPopup(new TimedBuffRebuyWindow());
         }
      }
      
      override public function get itemName() : String
      {
         var result:String = null;
         var subType:String = null;
         var itemXml:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            subType = Global.farmGameSettingsManager.getFarmItemByName(m_itemName).subType;
         }
         else
         {
            itemXml = Global.farmGameSettingsManager.getItemXMLByName(m_itemName);
            subType = itemXml.attribute(SUBTYPE_STRING);
         }
         switch(subType)
         {
            case ANIMAL_TYPE:
               result = ANIMAL_ITEM_NAME;
               break;
            case CRAFTING_TYPE:
               result = CRAFTING_ITEM_NAME;
               break;
            case TREE_TYPE:
               result = TREE_ITEM_NAME;
         }
         if(result == null)
         {
            result = m_itemName;
         }
         return result;
      }
   }
}

