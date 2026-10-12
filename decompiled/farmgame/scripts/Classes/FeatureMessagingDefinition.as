package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcon;
   import Events.FeatureMessageEvent;
   import Managers.FeatureMessagingManager;
   import Managers.ItemMembershipManager;
   import Managers.StaticCustomInitManager;
   import flash.utils.getDefinitionByName;
   
   public class FeatureMessagingDefinition
   {
      
      private static var m_classCompilingArray:Array = [ExternalInterfaceFeatureMessagingInit,ItemMembershipManager,FeatureMessagingBuildingDialogAction,CraftingBasketCustomInit,WanderingPirateFeatureMessagingInit,CommunityGoalsFeatureMessagingInit,IrrigationFeatureMessagingInit,StaticCustomInitManager,MultiDonateCustomInit,MystreeReskinCustomInit,FarmRunQuestsCustomInit,MiniDartCustomInit,BobBerryMessagingInit,BringBackWinterCustomInit,DragonBreedingCustomInit,FlowerShackCustomInit,GypsyTraderCustomInit,DollarBundlesCustomeInit,RegionAchievementFeatureMessagingInit,CraftingBasketDifficultyLevelsCustomInit,MystreeReskinDifficultyLevelsCustomInit,FestivalOfColorCustomInit,XMASInnovationCustomInit,LightningDealsCustomInit,TurtleInnovationCustomInit,JMInnovationCustomInit,AFInnovationCustomInit,WhitewinterInnovationCustomInit,MultiRewardTreasurePayerBundleCustomInit,MultiRewardTreasurePayerLandBundleCustomInit,MotdOnCustomInit,ChoiceDrivenCustomInit,CraftingBasketDifficultyLevelsCustomInit,OlyInnovationCustomInit
      ,XBOPremarketingCustomInit,DreamFishPremarketingCustomInit,SocialRaffleCustomInit,UGCFishCustomInit,StencilCustomInit,SubscriberWalletCustomInit,HalloweenUSAInnovationCustomInit1,PetAcademyCustomInit,TuscanyInnovationCustomInit,FarmRun2018CustomInit,MoneyTree2017CustomInit,PetAcademyCustomInit,ConsumableBundleCustomInit,GuildCustomInit,FarmRunV5CustomInit,FishingV2CustomInit,AntiqueMuseumCustomInit,FarmRunV7CustomInit,AnimalSanctuaryV2CustomInit,JumbleVillaCustomInit,PunchCardFeatureCustomInit,AntiqueMuseumV2CustomInit];
      
      public const ICON_SIDE_LEFT:String = "left";
      
      private var m_prereqs:Array;
      
      private var m_name:String;
      
      private var m_motd:String;
      
      private var m_iconDef:FeatureMessagingIconDefinition;
      
      private var m_icon:QueuedIcon;
      
      private var m_iconAdded:Boolean;
      
      private var m_customAction:IFeatureMessagingCustomAction;
      
      private var m_customInit:IFeatureMessagingCustomInit;
      
      private var m_difficultyLevel:IFeatureDifficultyLevels;
      
      public function FeatureMessagingDefinition(xml:XML)
      {
         var className:String = null;
         var customActionClass:Class = null;
         var customInitClass:Class = null;
         super();
         if(xml.prereqs)
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children());
         }
         if(xml.attribute("name"))
         {
            this.m_name = xml.attribute("name").toString();
         }
         if(xml.motd)
         {
            this.m_motd = xml.motd.toString();
         }
         if(xml.icon)
         {
            this.m_iconDef = new FeatureMessagingIconDefinition(xml.icon);
         }
         if(xml.hasOwnProperty("customAction"))
         {
            className = xml.customAction.attribute("class");
            customActionClass = getDefinitionByName("Classes." + className) as Class;
            this.m_customAction = new customActionClass(xml.customAction.children());
         }
         if(xml.hasOwnProperty("customInit"))
         {
            className = xml.customInit.attribute("class");
            customInitClass = getDefinitionByName(className) as Class;
            this.m_customInit = new customInitClass(xml);
         }
         this.m_iconAdded = false;
         FeatureMessagingManager.getInstance().addEventListener(FeatureMessageEvent.FEATURE_STATE_CHANGE,this.featureStateChange);
      }
      
      public function get icon() : FeatureMessagingIconDefinition
      {
         return this.m_iconDef;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get motd() : String
      {
         return this.m_motd;
      }
      
      public function passesPrereqs() : Boolean
      {
         var prereq:Object = null;
         var result:Boolean = true;
         for each(prereq in this.m_prereqs)
         {
            if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function passesIconPrereqs() : Boolean
      {
         var result:Boolean = this.passesPrereqs();
         if(this.m_iconDef)
         {
            result &&= this.m_iconDef.passesPrereqs();
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      private function featureStateChange(event:FeatureMessageEvent) : void
      {
         if(event.featureName == this.m_name)
         {
            this.updateIconVisibility();
         }
      }
      
      public function updateIconVisibility() : void
      {
         var shouldShow:Boolean = this.passesIconPrereqs();
         var iconIsVisible:Boolean = this.m_iconAdded;
         if(shouldShow != iconIsVisible)
         {
            if(shouldShow)
            {
               this.addIcon();
            }
            else
            {
               this.removeIcon();
            }
         }
      }
      
      public function get customAction() : IFeatureMessagingCustomAction
      {
         return this.m_customAction;
      }
      
      public function get customInit() : IFeatureMessagingCustomInit
      {
         return this.m_customInit;
      }
      
      private function addIcon() : void
      {
         var iconData:Object = null;
         if(Boolean(this.m_iconDef) && Boolean(!this.m_iconAdded) && DynamicIconQueue.checkIconBlacklist(this.m_name))
         {
            iconData = {"featureName":this.m_name};
            if(this.m_iconDef.tooltip)
            {
               iconData.iconTooltip = ZLocUtils.tk_pk_asTitle(this.m_iconDef.tooltip);
            }
            if(this.m_iconDef.endDate)
            {
               iconData.endDate = this.m_iconDef.endDate;
            }
            if(this.m_iconDef.removeOnClick)
            {
               iconData.removeOnClick = this.m_iconDef.removeOnClick;
            }
            if(this.m_iconDef.hudSide == this.ICON_SIDE_LEFT)
            {
               this.m_icon = Global.hud.iconQueue.addIcon(this.m_iconDef.type,DynamicIconQueue.ADD_BY_PRIORITY,this.m_iconDef.image,iconData,false);
            }
            else
            {
               this.m_icon = Global.hud.rightSideIconQueue.addIcon(this.m_iconDef.type,DynamicIconQueue.ADD_BY_PRIORITY,this.m_iconDef.image,iconData,false);
            }
            this.m_iconAdded = true;
         }
      }
      
      public function removeIcon() : void
      {
         if(Boolean(this.m_iconDef) && this.m_iconAdded)
         {
            if(this.m_iconDef.hudSide == this.ICON_SIDE_LEFT)
            {
               Global.hud.iconQueue.removeIcon(this.m_icon);
            }
            else
            {
               Global.hud.rightSideIconQueue.removeIcon(this.m_icon);
            }
            this.m_iconAdded = false;
         }
      }
   }
}

