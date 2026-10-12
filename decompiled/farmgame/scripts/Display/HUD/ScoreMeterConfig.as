package Display.HUD
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   
   public class ScoreMeterConfig
   {
      
      protected static const XP_BAR_COLOR:int = 16777215;
      
      public static const DEFAULT_LEVEL_FONT_COLOR:String = "0x764D1F";
      
      public static const LEVEL_FRAME_PATH:String = "assets/hud/FV_Main_LevelSign_loaded.png";
      
      public static const HUD_XP_BAR_PATH:String = "assets/hud/FV_XP_WhiteBar_loaded.png";
      
      private var m_levelFrameConfig:Object = null;
      
      private var m_barConfig:Object = null;
      
      private var m_whatIsThisConfig:Object = null;
      
      private var m_fontConfig:Object = null;
      
      private var m_overrideDialog:Object = null;
      
      private var m_bouncyArrowFlag:String = null;
      
      public function ScoreMeterConfig(xml:XML = null)
      {
         super();
         if(xml)
         {
            if(xml.hasOwnProperty("hudLevelFrame"))
            {
               this.m_levelFrameConfig = FarmGameUtil.xmlNodeToAttributes(xml["hudLevelFrame"][0]);
            }
            if(xml.hasOwnProperty("hudXPBar"))
            {
               this.m_barConfig = FarmGameUtil.xmlNodeToAttributes(xml["hudXPBar"][0]);
            }
            if(xml.hasOwnProperty("whatIsThis"))
            {
               this.m_whatIsThisConfig = FarmGameUtil.xmlNodeToAttributes(xml["whatIsThis"][0]);
            }
            if(xml.hasOwnProperty("font"))
            {
               this.m_fontConfig = FarmGameUtil.xmlNodeToAttributes(xml["font"][0]);
            }
            if(xml.hasOwnProperty("overrideDialog"))
            {
               this.m_overrideDialog = FarmGameUtil.xmlNodeToAttributes(xml["overrideDialog"][0]);
            }
            if(xml.hasOwnProperty("bouncyArrowFlag"))
            {
               this.m_bouncyArrowFlag = FarmGameUtil.xmlNodeToAttributes(xml["bouncyArrowFlag"][0])["name"];
            }
         }
      }
      
      public function get framePath() : String
      {
         var framePath:String = ScoreMeterConfig.LEVEL_FRAME_PATH;
         if(Boolean(this.m_levelFrameConfig) && this.m_levelFrameConfig.hasOwnProperty("path"))
         {
            framePath = this.m_levelFrameConfig["path"];
         }
         return framePath;
      }
      
      public function get bouncyArrowFlag() : String
      {
         return this.m_bouncyArrowFlag;
      }
      
      public function get frameX() : Number
      {
         var aFrameX:Number = 0;
         if(Boolean(this.m_levelFrameConfig) && this.m_levelFrameConfig.hasOwnProperty("x"))
         {
            aFrameX = Number(this.m_levelFrameConfig["x"]);
         }
         return aFrameX;
      }
      
      public function get frameY() : Number
      {
         var aFrameY:Number = -6;
         if(Boolean(this.m_levelFrameConfig) && this.m_levelFrameConfig.hasOwnProperty("y"))
         {
            aFrameY = Number(this.m_levelFrameConfig["y"]);
         }
         return aFrameY;
      }
      
      public function get barPath() : String
      {
         var barPath:String = ScoreMeterConfig.HUD_XP_BAR_PATH;
         if(Boolean(this.m_barConfig) && this.m_barConfig.hasOwnProperty("path"))
         {
            barPath = this.m_barConfig["path"];
         }
         return barPath;
      }
      
      public function get barX() : Number
      {
         var barX:Number = 10;
         if(Boolean(this.m_barConfig) && this.m_barConfig.hasOwnProperty("x"))
         {
            barX = Number(this.m_barConfig["x"]);
         }
         return barX;
      }
      
      public function get barY() : Number
      {
         var barY:Number = 6;
         if(Boolean(this.m_barConfig) && Boolean(this.m_barConfig["y"]))
         {
            barY = Number(this.m_barConfig["y"]);
         }
         return barY;
      }
      
      public function get barWidth() : Number
      {
         var barWidth:Number = 60;
         if(Boolean(this.m_barConfig) && this.m_barConfig.hasOwnProperty("width"))
         {
            barWidth = Number(this.m_barConfig["width"]);
         }
         return barWidth;
      }
      
      public function get fontColor() : String
      {
         var fontColor:String = DEFAULT_LEVEL_FONT_COLOR;
         if(Boolean(this.m_fontConfig) && this.m_fontConfig.hasOwnProperty("color"))
         {
            fontColor = this.m_fontConfig["color"].toString();
         }
         return fontColor;
      }
      
      public function get fontXOffset() : int
      {
         var result:int = 38;
         if(Boolean(this.m_fontConfig) && this.m_fontConfig.hasOwnProperty("offsetX"))
         {
            result = int(this.m_fontConfig["offsetX"]);
         }
         return result;
      }
      
      public function get fontYOffset() : int
      {
         var result:int = 4;
         if(Boolean(this.m_fontConfig) && this.m_fontConfig.hasOwnProperty("offsetY"))
         {
            result = int(this.m_fontConfig["offsetY"]);
         }
         return result;
      }
      
      public function get overrideDialogClass() : String
      {
         var result:String = null;
         if(Boolean(this.m_overrideDialog) && this.m_overrideDialog.hasOwnProperty("class"))
         {
            if(this.m_overrideDialog["class"] != "")
            {
               result = this.m_overrideDialog["class"];
            }
         }
         return result;
      }
      
      public function getOverrideDialogParam(paramName:String, defaultVal:String) : String
      {
         var result:String = null;
         if(Boolean(this.m_overrideDialog) && this.m_overrideDialog.hasOwnProperty(paramName))
         {
            if(this.m_overrideDialog[paramName] != "")
            {
               result = this.m_overrideDialog[paramName];
            }
            else
            {
               result = defaultVal;
            }
         }
         return result;
      }
      
      public function hasWhatIsThis() : Boolean
      {
         return this.m_whatIsThisConfig != null;
      }
      
      public function getWhatIsThisDialogParams(scoreUnit:String, currentScore:Number, currentLevel:Number) : Array
      {
         var level:int = 0;
         var requiredXP:Number = NaN;
         var neededXP:Number = NaN;
         var rewards:Vector.<Object> = null;
         var farmItem:FarmItem = null;
         var prizes:String = null;
         var prizeNum:int = 0;
         var prizeName:String = null;
         var index:int = 0;
         var scoreUnitFriendly:String = null;
         var mainText:Object = null;
         var params:Array = null;
         if(this.m_whatIsThisConfig)
         {
            level = Global.worldScoreSettingsManager.getLevelForScore(scoreUnit,currentScore,currentLevel);
            requiredXP = Global.worldScoreSettingsManager.getRequiredScoreForLevel(scoreUnit,level + 1);
            neededXP = requiredXP - Global.player.getWorldScore(scoreUnit);
            rewards = Global.worldScoreSettingsManager.getRewardsForLevel(scoreUnit,level + 1);
            prizes = "";
            prizeNum = 0;
            prizeName = "";
            for(index = 0; index < rewards.length; index++)
            {
               if(rewards[index].type == QuestConstants.REWARD_DISPLAY_ONLY)
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(rewards[index].value);
                  if(null == farmItem)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewards[index].value);
                  }
               }
               if(farmItem)
               {
                  prizeName = ZLocUtils.t_pk(farmItem.friendlyName);
               }
               else if(rewards[index].type == QuestConstants.REWARD_WORLD_CURRENCY)
               {
                  prizeName = rewards[index].value + " " + ZLocUtils.t_pk("FarmGame",rewards[index].unit);
               }
               else
               {
                  prizeName = "";
               }
               if(prizeName != "")
               {
                  if(++prizeNum > 1)
                  {
                     if(prizeNum < rewards.length)
                     {
                        prizes += ", ";
                     }
                     else
                     {
                        prizes += ", " + ZLocUtils.t_pk("FarmGame","and") + " ";
                     }
                  }
                  prizes += prizeName;
               }
               farmItem = null;
            }
            scoreUnitFriendly = ZLocUtils.t("FarmGame",scoreUnit);
            mainText = ZLocUtils.t_pk(this.m_whatIsThisConfig["text"],null,{
               "prizes":prizes,
               "numPoints":neededXP,
               "nextLevel":currentLevel + 1,
               "scoreUnit":ZLocUtils.t("FarmGame",scoreUnit)
            });
            params = [this.m_whatIsThisConfig["icon"].toString(),mainText];
            if(this.m_whatIsThisConfig.hasOwnProperty("title"))
            {
               if(ZLocUtils.isObject(this.m_whatIsThisConfig["title"]))
               {
                  params.push(ZLocUtils.tk_pk_asTitle(this.m_whatIsThisConfig["title"]));
               }
               else
               {
                  params.push(ZLocUtils.t_pk(this.m_whatIsThisConfig["title"],null,{"level":currentLevel}));
               }
            }
            if(this.m_whatIsThisConfig.hasOwnProperty("buttonText"))
            {
               params.push(ZLocUtils.t_pk(this.m_whatIsThisConfig["buttonText"]));
            }
            if(this.m_whatIsThisConfig.hasOwnProperty("cancelButtonText"))
            {
               params.push(ZLocUtils.t_pk(this.m_whatIsThisConfig["cancelButtonText"]));
            }
         }
         return params;
      }
   }
}

