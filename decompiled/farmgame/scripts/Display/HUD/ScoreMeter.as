package Display.HUD
{
   import Classes.EmbeddedArt;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.FarmGameSprite;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class ScoreMeter extends FarmGameSprite
   {
      
      public static const DEFAULT_TOOLTIP_WIDTH:Number = 220;
      
      public static const WHAT_IS_THIS_DIALOG_NAME:String = "WorldScoreWhatIsThis";
      
      private static const POSTFIX_SKIP_FIRST_VIEW:String = "Skip1stView";
      
      private static const MSEC_DISPLAY_UPDATE_DELAY:uint = 100;
      
      private var m_displayIncreaseAmount:int = 0;
      
      private var m_displayDelayTimer:Timer = null;
      
      private var m_xp:Number = 0;
      
      private var m_level:Number = 0;
      
      private var m_scoreUnit:String = null;
      
      private var m_xpBar:DisplayObject = null;
      
      private var m_levelText:TextField;
      
      private var m_levelFrame:DisplayObject = null;
      
      private var m_config:ScoreMeterConfig = null;
      
      private var m_initialPopulationComplete:Boolean = false;
      
      private var m_bouncingArrow:DisplayObject = null;
      
      public function ScoreMeter()
      {
         super();
      }
      
      public function init(scoreMeterConfig:ScoreMeterConfig) : void
      {
         this.clearChildren();
         this.m_config = scoreMeterConfig;
         LoadingManager.load(Global.getAssetURL(this.m_config.framePath),this.onFrameLoaded,LoadingManager.PRIORITY_HIGH);
         LoadingManager.load(Global.getAssetURL(this.m_config.barPath),this.onBarLoaded,LoadingManager.PRIORITY_HIGH);
      }
      
      public function onFrameLoaded(event:Event) : void
      {
         var bouncyArrowFlag:String = null;
         if(event.target.content is DisplayObject)
         {
            this.m_levelFrame = event.target.content;
            this.m_levelFrame.y = this.m_config.frameY;
            addChildAt(this.m_levelFrame,0);
            this.m_levelText = new TextField();
            this.m_levelText.selectable = false;
            this.m_levelText.width = 30;
            this.m_levelText.autoSize = TextFieldAutoSize.LEFT;
            this.m_levelText.embedFonts = true;
            this.m_levelText.mouseWheelEnabled = false;
            Utilities.toggleInputOnlySelf(this.m_levelText,false);
            this.m_levelText.mouseWheelEnabled = false;
            this.refreshLevelText();
            addChild(this.m_levelText);
            if(this.m_config.hasWhatIsThis())
            {
               addEventListener(MouseEvent.CLICK,this.onClick);
               useHandCursor = true;
            }
            bouncyArrowFlag = this.m_config.bouncyArrowFlag;
            if(bouncyArrowFlag != null && !Global.player.getSeenFlag(bouncyArrowFlag))
            {
               if(!Global.player.getSeenFlag(bouncyArrowFlag + POSTFIX_SKIP_FIRST_VIEW))
               {
                  Global.player.setSeenFlag(bouncyArrowFlag + POSTFIX_SKIP_FIRST_VIEW);
               }
               else
               {
                  this.setArrowVisible(true);
               }
            }
         }
      }
      
      public function setArrowVisible(visible:Boolean) : void
      {
         if(visible)
         {
            if(!this.m_bouncingArrow)
            {
               this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
               this.m_bouncingArrow.x = 35;
               this.m_bouncingArrow.y = 110;
               this.m_bouncingArrow.scaleX = 1;
               this.m_bouncingArrow.scaleY = -1;
               this.addChild(this.m_bouncingArrow);
            }
         }
         else if(this.m_bouncingArrow)
         {
            this.removeChild(this.m_bouncingArrow);
            this.m_bouncingArrow = null;
         }
      }
      
      public function onBarLoaded(event:Event) : void
      {
         var xpStroke:GlowFilter = null;
         if(event.target.content is DisplayObject)
         {
            this.m_xpBar = event.target.content;
            xpStroke = new GlowFilter();
            xpStroke.blurX = xpStroke.blurY = 1.3;
            xpStroke.color = 7752991;
            xpStroke.alpha = 1;
            xpStroke.quality = BitmapFilterQuality.HIGH;
            xpStroke.strength = 30;
            this.m_xpBar.x = this.m_config.barX;
            this.m_xpBar.y = this.m_config.barY;
            this.m_xpBar.width = this.m_config.barWidth;
            this.xp = this.m_xp;
            addChild(this.m_xpBar);
            Global.hud.conditionallyRefreshHUD(true);
            this.m_initialPopulationComplete = true;
         }
      }
      
      private function onClick(event:MouseEvent) : void
      {
         var dynamicClass:Class = null;
         var addToQueue:Boolean = false;
         var popupName:String = null;
         var checkDuplicates:Boolean = false;
         var dialogParams:Array = null;
         var displayPopup:DataDrivenOkayPopup = null;
         var type:String = this.m_config.getOverrideDialogParam("type","dialog");
         if(this.m_bouncingArrow != null)
         {
            Global.player.setSeenFlag(this.m_config.bouncyArrowFlag);
            this.setArrowVisible(false);
         }
         if(type)
         {
            if(type == DecoPointsManager.DIALOG_PHOTO_UI)
            {
               FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,DecoPointsManager.DECOPOINTS_TOPBAR,DecoPointsManager.DECOPOINTS_DIALOG_CLICK);
               DecoPointsManager.instance.openDecoPointsMainUI();
            }
            else if(type == "dialog")
            {
               dynamicClass = getDefinitionByName(this.m_config.overrideDialogClass) as Class;
               addToQueue = this.m_config.getOverrideDialogParam("addToQueue","true") == "true";
               popupName = this.m_config.getOverrideDialogParam("popupName","");
               checkDuplicates = this.m_config.getOverrideDialogParam("checkDuplicates","false") == "true";
               UI.displayPopup(new dynamicClass() as DisplayObject,addToQueue,popupName,checkDuplicates);
            }
         }
         else
         {
            dialogParams = this.m_config.getWhatIsThisDialogParams(this.m_scoreUnit,this.m_xp,this.m_level);
            displayPopup = new DataDrivenOkayPopup(WHAT_IS_THIS_DIALOG_NAME,dialogParams);
            UI.displayPopup(displayPopup,false);
         }
      }
      
      public function set xp(amount:Number) : void
      {
         var lastRequiredXP:Number = NaN;
         var xpPct:Number = 0;
         var requiredXP:Number = 0;
         var neededXP:Number = 0;
         var delta:Number = amount - this.m_xp;
         this.m_xp = amount;
         if(amount >= 0)
         {
            if(null != this.m_scoreUnit)
            {
               this.level = Global.worldScoreSettingsManager.getLevelForScore(this.m_scoreUnit,amount,this.m_level);
               lastRequiredXP = Global.worldScoreSettingsManager.getRequiredScoreForLevel(this.m_scoreUnit,this.m_level);
               requiredXP = Global.worldScoreSettingsManager.getRequiredScoreForLevel(this.m_scoreUnit,this.m_level + 1);
               neededXP = requiredXP - Global.player.getWorldScore(this.m_scoreUnit);
               xpPct = (amount - lastRequiredXP) / (requiredXP - lastRequiredXP);
            }
            else
            {
               this.level = Global.farmGameSettingsManager.getLevelForXP(amount);
               requiredXP = Global.farmGameSettingsManager.getXPForLevel(this.level + 1);
               neededXP = requiredXP - Global.player.xp;
               xpPct = Global.farmGameSettingsManager.getLevelProgressForXP(amount);
            }
         }
         else
         {
            this.level = 1;
         }
         var barWidth:int = this.m_config.barWidth;
         if(this.m_xpBar)
         {
            this.m_xpBar.width = xpPct * barWidth;
         }
         var scoreUnit:String = "";
         if(this.m_scoreUnit)
         {
            scoreUnit = ZLocUtils.t("FarmGame",this.m_scoreUnit);
            toolTip = ZLocUtils.t("FarmGame",this.m_scoreUnit + "_ToolTip_click",{
               "xpNum":amount,
               "unit":scoreUnit,
               "requiredXP":neededXP,
               "levelNum":this.level + 1
            });
            if(toolTip == null || toolTip == "")
            {
               toolTip = ZLocUtils.t("FarmGame","XP_ToolTip_click",{
                  "xpNum":amount,
                  "unit":scoreUnit,
                  "requiredXP":neededXP,
                  "levelNum":this.level + 1
               });
            }
         }
         else
         {
            scoreUnit = ZLocUtils.t("FarmGame","xp");
            toolTip = ZLocUtils.t("FarmGame","XP_ToolTip2",{
               "xpNum":amount,
               "unit":scoreUnit,
               "requiredXP":neededXP,
               "levelNum":this.level + 1
            });
         }
         if(delta > 0 && this.m_scoreUnit != null && this.m_initialPopulationComplete)
         {
            this.displayUpdate(delta);
         }
      }
      
      public function set level(amount:Number) : void
      {
         this.m_level = amount;
         this.refreshLevelText();
      }
      
      public function get level() : Number
      {
         return this.m_level;
      }
      
      public function refreshLevelText() : void
      {
         var textFormat:TextFormat = null;
         if(this.m_levelText)
         {
            if(this.level > 99)
            {
               this.m_levelText.x = this.m_levelFrame.width - this.m_config.fontXOffset;
               this.m_levelText.y = this.m_config.fontYOffset;
               textFormat = HUDFonts.SmallLevelText;
            }
            else
            {
               this.m_levelText.x = this.m_levelFrame.width - this.m_config.fontXOffset;
               this.m_levelText.y = this.m_config.fontYOffset;
               textFormat = HUDFonts.LevelText;
            }
            textFormat.color = this.m_config.fontColor;
            this.m_levelText.defaultTextFormat = textFormat;
            this.m_levelText.setTextFormat(textFormat);
            this.m_levelText.text = FarmGameUtil.numberToStringPadZeros(this.level);
         }
      }
      
      private function clearChildren() : void
      {
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
      }
      
      public function set scoreUnit(aScoreUnit:String) : void
      {
         this.m_scoreUnit = aScoreUnit;
      }
      
      public function get scoreUnit() : String
      {
         return this.m_scoreUnit;
      }
      
      public function release() : void
      {
         this.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.clearChildren();
         this.m_xpBar = null;
         this.m_levelText = null;
         this.m_config = null;
      }
      
      public function displayUpdate(amount:int) : void
      {
         this.m_displayIncreaseAmount += amount;
         if(this.m_displayDelayTimer == null)
         {
            this.m_displayDelayTimer = new Timer(MSEC_DISPLAY_UPDATE_DELAY,0);
            this.m_displayDelayTimer.addEventListener(TimerEvent.TIMER,this.onDisplayUpdate);
            this.m_displayDelayTimer.start();
         }
      }
      
      private function onDisplayUpdate(event:TimerEvent) : void
      {
         var amount:int = this.m_displayIncreaseAmount;
         this.m_displayIncreaseAmount = 0;
         this.m_displayDelayTimer.removeEventListener(TimerEvent.TIMER,this.onDisplayUpdate);
         this.m_displayDelayTimer.stop();
         this.m_displayDelayTimer = null;
         var message:String = ZLocUtils.t("FarmGame","Status_AddZP",{
            "points":amount,
            "name":ZLocUtils.t("FarmGame",this.m_scoreUnit)
         });
         UI.displayStatus(message,this.x,this.y + this.height);
      }
   }
}

