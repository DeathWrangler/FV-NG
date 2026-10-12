package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Managers.BeatExpansion.BeatExpansionBaseManager;
   import flash.utils.getDefinitionByName;
   
   public class BeatExpansionQueuedIcon extends QueuedIconWithArrow
   {
      
      private static const BEAT_MANAGER_CLASS_PREFIX:String = "Managers.BeatExpansion.";
      
      private var m_managerClassName:String;
      
      private var m_beatManager:BeatExpansionBaseManager;
      
      public function BeatExpansionQueuedIcon(xml:XML)
      {
         this.m_managerClassName = xml.managerClass;
         super(xml);
      }
      
      override public function init() : void
      {
         var fullClassName:String = BEAT_MANAGER_CLASS_PREFIX + this.m_managerClassName;
         var beatManagerClass:Class = getDefinitionByName(fullClassName) as Class;
         this.m_beatManager = beatManagerClass.instance as BeatExpansionBaseManager;
         extraData["iconTooltip"] = ZLocUtils.t("Dialogs",this.m_beatManager.queuedLocalizationPrefix + "Tooltip");
         super.init();
      }
      
      override public function finishClick(queue:DynamicIconQueue) : void
      {
         super.finishClick(queue);
         this.m_beatManager.displayUI();
         this.m_beatManager.setQuestAsSeen();
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         switch(arrowType)
         {
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t("Dialogs",this.m_beatManager.queuedLocalizationPrefix + "NewArrow"));
               break;
            case ArrowType.ARROWUPDATE:
               setArrowText(ZLocUtils.t("Dialogs","Progress"));
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
   }
}

