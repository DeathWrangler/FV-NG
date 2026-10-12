package Widgets.Windows
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.EmbeddedArt;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Managers.AOEManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import flash.display.DisplayObject;
   import flash.text.TextField;
   
   public class AOETooltip extends ZwAbstractWindow
   {
      
      public static const MODE_SHOW_MULTIPLIERS:int = 0;
      
      public static const MODE_SHOW_BONUS_AVAILABLE:int = 1;
      
      public static const MODE_SHOW_STACKED_BONUS_AVAILABLE:int = 2;
      
      protected var m_bonusMultiplierParams:Object;
      
      protected var m_bonusCumulativeParams:Object;
      
      protected var m_mode:int;
      
      protected var m_itemFriendlyName:String;
      
      protected var m_tooltipDisplayObject:DisplayObject;
      
      private var m_locKey:String;
      
      private var m_count:int = 0;
      
      private var m_possibleStates:Array = null;
      
      public function AOETooltip(mode:int, itemFriendlyName:String, bonusData:AOEBonusData = null)
      {
         super(null);
         if(bonusData)
         {
            this.m_bonusMultiplierParams = bonusData.bonusMultiplierTypes;
            this.m_bonusCumulativeParams = bonusData.bonusCumulativeTypes;
            this.m_locKey = bonusData.locKey;
            this.m_possibleStates = bonusData.possibleStates;
         }
         this.m_mode = mode;
         this.m_itemFriendlyName = itemFriendlyName != null ? itemFriendlyName : "";
         this.m_tooltipDisplayObject = new EmbeddedArt.aoeTooltipMC() as DisplayObject;
         this.hideElements();
         this.addChild(this.m_tooltipDisplayObject);
         this.renderUI();
      }
      
      protected function renderUI() : void
      {
         if(this.m_mode == MODE_SHOW_MULTIPLIERS)
         {
            this.showMultipliers();
         }
         else if(this.m_mode == MODE_SHOW_BONUS_AVAILABLE)
         {
            this.showBonusAvailable(false);
         }
         else if(this.m_mode == MODE_SHOW_STACKED_BONUS_AVAILABLE)
         {
            this.showBonusAvailable(true);
         }
         if(this.m_count == 0)
         {
            if(this.m_possibleStates != null && this.m_possibleStates.length > 0)
            {
               this.visible = false;
            }
            else
            {
               this.visible = true;
            }
         }
         else
         {
            this.visible = true;
            this.m_count = 0;
         }
      }
      
      private function showMultipliers() : void
      {
         var defaultBonusObject:Object = null;
         var key:String = null;
         var containingClip:ZwFrame = null;
         var statusString:String = null;
         var textClipname:String = null;
         var percentage:Number = NaN;
         var keyCount:int = 0;
         var affectedBonusMultipliers:Object = new Object();
         var affectedCumulativeBonuses:Object = new Object();
         this.m_count = 0;
         if(this.m_bonusMultiplierParams != null)
         {
            defaultBonusObject = AOEManager.getInstance().getDefaultBonusMultiplierObject();
            for(key in this.m_bonusMultiplierParams)
            {
               if(this.m_bonusMultiplierParams[key] > this.getDefaultMultiplier(key,defaultBonusObject))
               {
                  affectedBonusMultipliers[key] = this.m_bonusMultiplierParams[key];
                  ++this.m_count;
               }
            }
         }
         if(this.m_bonusCumulativeParams != null)
         {
            defaultBonusObject = AOEManager.getInstance().getDefaultBonusCumulativeObject();
            for(key in this.m_bonusCumulativeParams)
            {
               if(this.m_bonusCumulativeParams[key] > this.getDefaultMultiplier(key,defaultBonusObject))
               {
                  affectedCumulativeBonuses[key] = this.m_bonusCumulativeParams[key];
                  ++this.m_count;
               }
            }
         }
         var clipname:String = this.getClipname(this.m_count);
         if(this.m_tooltipDisplayObject.hasOwnProperty(clipname) && this.m_tooltipDisplayObject[clipname] != null)
         {
            containingClip = new ZwFrame(this.m_tooltipDisplayObject[clipname]);
            this.addWidget(containingClip);
            keyCount = 0;
            for(key in affectedBonusMultipliers)
            {
               if(key != AOEManager.HARVEST_YIELD_BONUS_KEY)
               {
                  percentage = Math.round((affectedBonusMultipliers[key] - this.getDefaultMultiplier(key,defaultBonusObject)) * 100);
                  statusString = ZLocUtils.t("Dialogs","AOEBonusText_" + key,{"percentage":percentage.toString()});
                  textClipname = "body" + keyCount + "_tf";
                  if(containingClip.element.hasOwnProperty(textClipname) && containingClip.element[textClipname] != null)
                  {
                     containingClip.addWidget(new ZwTextField(containingClip.element[textClipname],statusString));
                     (containingClip.element[textClipname] as TextField).selectable = false;
                  }
                  keyCount++;
               }
            }
            for(key in affectedCumulativeBonuses)
            {
               if(key != AOEManager.HARVEST_YIELD_BONUS_KEY)
               {
                  statusString = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs","AOEBonusText_cumulative_" + this.m_locKey + "_" + key),new ZLocFailoverEntry("Dialogs","AOEBonusText_cumulative_" + key)],{"amount":affectedCumulativeBonuses[key].toString()});
                  textClipname = "body" + keyCount + "_tf";
                  if(containingClip.element.hasOwnProperty(textClipname) && containingClip.element[textClipname] != null)
                  {
                     containingClip.addWidget(new ZwTextField(containingClip.element[textClipname],statusString));
                     (containingClip.element[textClipname] as TextField).selectable = false;
                  }
                  keyCount++;
               }
            }
         }
         if(this.m_tooltipDisplayObject.hasOwnProperty("title_tf") && this.m_tooltipDisplayObject["title_tf"] != null)
         {
            this.addWidget(new ZwTextField(this.m_tooltipDisplayObject["title_tf"],ZLocUtils.t("Dialogs","AoeBonusTitle",{"item":this.m_itemFriendlyName})));
         }
      }
      
      private function showBonusAvailable(isStacked:Boolean) : void
      {
         if(isStacked)
         {
            if(this.m_tooltipDisplayObject.hasOwnProperty("title_1_tf") && this.m_tooltipDisplayObject["title_1_tf"] != null)
            {
               this.addWidget(new ZwTextField(this.m_tooltipDisplayObject["title_1_tf"],ZLocUtils.t("Dialogs","AoeExtraBonusTitle",{"item":this.m_itemFriendlyName})));
               (this.m_tooltipDisplayObject["title_1_tf"] as TextField).selectable = false;
            }
         }
         else if(this.m_tooltipDisplayObject.hasOwnProperty("title_0_tf") && this.m_tooltipDisplayObject["title_0_tf"] != null)
         {
            this.addWidget(new ZwTextField(this.m_tooltipDisplayObject["title_0_tf"],ZLocUtils.t("Dialogs","AoeBonusTitle",{"item":this.m_itemFriendlyName})));
            (this.m_tooltipDisplayObject["title_0_tf"] as TextField).selectable = false;
         }
      }
      
      private function getClipname(count:int) : String
      {
         var clipname:String = null;
         switch(count)
         {
            case 1:
               clipname = "oneLine_mc";
               break;
            case 2:
               clipname = "twoLines_mc";
               break;
            case 3:
               clipname = "threeLines_mc";
               break;
            default:
               clipname = "threeLines_mc";
         }
         return clipname;
      }
      
      private function getDefaultMultiplier(key:String, defaultBonusObject:Object) : Number
      {
         var result:Number = 1;
         if(defaultBonusObject.hasOwnProperty(key))
         {
            result = Number(defaultBonusObject[key]);
         }
         return result;
      }
      
      private function hideElements() : void
      {
         if(this.m_tooltipDisplayObject["title_0_tf"])
         {
            this.m_tooltipDisplayObject["title_0_tf"].visible = false;
         }
         if(this.m_tooltipDisplayObject["title_1_tf"])
         {
            this.m_tooltipDisplayObject["title_1_tf"].visible = false;
         }
         if(this.m_tooltipDisplayObject["title_tf"])
         {
            this.m_tooltipDisplayObject["title_tf"].visible = false;
         }
         if(this.m_tooltipDisplayObject["oneLine_mc"])
         {
            this.m_tooltipDisplayObject["oneLine_mc"].visible = false;
         }
         if(this.m_tooltipDisplayObject["twoLines_mc"])
         {
            this.m_tooltipDisplayObject["twoLines_mc"].visible = false;
         }
         if(this.m_tooltipDisplayObject["threeLines_mc"])
         {
            this.m_tooltipDisplayObject["threeLines_mc"].visible = false;
         }
      }
   }
}

