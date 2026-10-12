package Widgets.Windows.CrossPromo
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.CrossPromoSign;
   import flash.display.MovieClip;
   
   public class EmpiresAlliesCrossPromoWindow extends CrossPromoWindow
   {
      
      private const NUM_CHARACTERS:Number = 4;
      
      public function EmpiresAlliesCrossPromoWindow(showCheckbox:Boolean = false, empiresSign:CrossPromoSign = null)
      {
         super("assets/dialogs/4d_elements/Nina_xPromo/FV_xpromo_EmpiresAllies.swf","empire_xpromo",null,showCheckbox,empiresSign);
      }
      
      override protected function postLoadComplete() : void
      {
         var character:MovieClip = null;
         super.postLoadComplete();
         for(var i:int = 0; i < this.NUM_CHARACTERS; i++)
         {
            character = m_window.mainWindow["character_" + i] as MovieClip;
            if(character)
            {
               character.play();
            }
         }
      }
      
      override protected function setBillboardRemoveSeenFlag() : void
      {
         Global.player.setSeenFlag(CrossPromoConstants.EMPIRESALLIES_REMOVE_BILLBOARD);
      }
   }
}

