package Display
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GarageButton extends GenericButton
   {
      
      protected var m_key:String = "";
      
      protected var m_upgradeParts:Number = 0;
      
      public function GarageButton(target_mc:MovieClip, clickCallback:Function = null, key:String = "", upgradeParts:Number = 0, val:String = "", overlayName:String = "")
      {
         this.m_key = key;
         this.m_upgradeParts = upgradeParts;
         super(target_mc,clickCallback,val,overlayName);
      }
      
      override protected function handleClickCallback(event:MouseEvent) : void
      {
         callback(event.target.name,this.m_key,this.m_upgradeParts);
      }
   }
}

