package Init.PostInitActionHandlers
{
   import Classes.CrossPromoDescriptor;
   
   public class RightSideHudIconXPromoInitAction extends AbstractPostInitAction
   {
      
      public function RightSideHudIconXPromoInitAction(callback:Function = null)
      {
         super(callback);
      }
      
      override public function execute() : void
      {
         var crossPromo:CrossPromoDescriptor = null;
         var queuedIconXML:XML = null;
         var iconName:String = null;
         var activeCrossPromos:Object = Global.crosspromoDescriptorManager.crossPromos;
         for each(crossPromo in activeCrossPromos)
         {
            if(crossPromo.hasHudIcon())
            {
               queuedIconXML = Global.farmGameSettingsManager.getIconXMLByCode(crossPromo.hudIconId.toString());
               if(queuedIconXML != null)
               {
                  iconName = queuedIconXML.@name.toString();
                  Global.hud.rightSideIconQueue.addIcon(iconName,queuedIconXML.priority.toString(),null,null,false);
               }
            }
         }
         m_isFinished = true;
      }
   }
}

