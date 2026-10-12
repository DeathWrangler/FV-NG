package Classes
{
   import Classes.util.ZLocUtils;
   
   public class Achievement extends GameSettingsObject
   {
      
      private var m_level:int = -1;
      
      public function Achievement(xml:XML)
      {
         super(xml);
      }
      
      override protected function getFriendlyNameLocFile() : String
      {
         return "Achievements";
      }
      
      public function getCurrentCount() : int
      {
         return Global.player.achCounters[this.code] != null ? int(parseInt(Global.player.achCounters[this.code])) : 0;
      }
      
      public function get code() : String
      {
         return m_xml.@code;
      }
      
      public function get showIn() : String
      {
         var result:String = "";
         if(m_xml.@showIn)
         {
            result = m_xml.@showIn;
         }
         return result;
      }
      
      public function get isDisabled() : Boolean
      {
         return "true" == m_xml.@disabled;
      }
      
      public function get levels() : XMLList
      {
         return m_xml.level;
      }
      
      public function get currentLevel() : int
      {
         var highestLevel:int = 0;
         if(this.m_level == -1 && Global.player.achievements[this.code] != null)
         {
            highestLevel = parseInt(Global.player.achievements[this.code]);
         }
         else
         {
            highestLevel = this.m_level;
         }
         return highestLevel;
      }
      
      public function set currentLevel(level:int) : void
      {
         this.m_level = level;
      }
      
      public function get nextLevel() : int
      {
         return this.currentLevel + 1;
      }
      
      public function get xp() : int
      {
         var level:XML = this.levels[this.currentLevel];
         return level.@xp;
      }
      
      public function get gold() : int
      {
         var level:XML = this.levels[this.currentLevel];
         return level.@coins;
      }
      
      public function get gift() : String
      {
         var level:XML = this.levels[this.currentLevel];
         return level.@gift;
      }
      
      public function get nextRibbon() : String
      {
         var ribbonName:String = "";
         switch(this.currentLevel)
         {
            case 0:
               ribbonName = "WhiteRibbon";
               break;
            case 1:
               ribbonName = "RedRibbon";
               break;
            case 2:
               ribbonName = "BlueRibbon";
               break;
            case -1:
            default:
               ribbonName = "YellowRibbon";
         }
         return ribbonName;
      }
      
      public function get nextRibbonColor() : String
      {
         var ribbonName:String = "";
         switch(this.currentLevel)
         {
            case 0:
               ribbonName = "White";
               break;
            case 1:
               ribbonName = "Red";
               break;
            case 2:
               ribbonName = "Blue";
         }
         return ribbonName;
      }
      
      public function get currentRibbon() : String
      {
         var ribbonName:String = "";
         switch(this.currentLevel)
         {
            case 1:
               ribbonName = "WhiteRibbon";
               break;
            case 2:
               ribbonName = "RedRibbon";
               break;
            case 3:
               ribbonName = "BlueRibbon";
               break;
            case 0:
            default:
               ribbonName = "YellowRibbon";
         }
         return ribbonName;
      }
      
      public function hasAllAchievements() : Boolean
      {
         return this.currentLevel >= 3;
      }
      
      public function get countToNextLevel() : int
      {
         var level:XML = this.levels[this.nextLevel];
         return level.@count - this.getCurrentCount();
      }
      
      public function get description() : String
      {
         var returnStr:String = null;
         var level:XML = null;
         var reqNum:int = 0;
         if(this.hasAllAchievements() == true)
         {
            returnStr = ZLocUtils.t("Achievements","AllRibbons");
         }
         else
         {
            level = this.levels[this.nextLevel];
            reqNum = parseInt(level.@count);
            returnStr = ZLocUtils.t("Achievements",name + "_description",{
               "requiredNum":reqNum,
               "word":ZLocUtils.tk("Achievements",name + "_word","",reqNum),
               "colorribbon":ZLocUtils.tk("Achievements",this.nextRibbon,"definite"),
               "remainingNum":reqNum - this.getCurrentCount()
            });
         }
         return returnStr;
      }
      
      public function get title() : String
      {
         return this.getFriendlyNameLocFile() + ":" + name + "_title";
      }
      
      override public function get friendlyName() : String
      {
         return this.getFriendlyNameLocFile() + ":" + name + "_Ribbon_friendlyName";
      }
   }
}

