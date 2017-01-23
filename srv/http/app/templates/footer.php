<div id="poweroff-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="poweroff-modal-label" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-body txtmid">
                <button id="reboot" class="btn btn-primary btn-lg btn-block" data-dismiss="modal"><i class="fa fa-refresh"></i> Reboot</button>
                &nbsp;
                <button id="poweroff" class="btn btn-primary btn-lg btn-block" data-dismiss="modal"><i class="fa fa-power-off"></i> Shut down</button>
            </div>
        </div>
    </div>
</div>
<!-- loader -->
<div id="loader"<?php if ($this->section == 'dev') { ?> class="hide"<?php } ?>><div id="loaderbg"></div><div id="loadercontent"><i class="fa fa-refresh fa-spin"></i>connecting...</div></div>
<script src="<?=$this->asset('/js/vendor/jquery-2.1.0.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/pushstream.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/bootstrap.min.js')?>"></script>
<?php if ($this->section == 'debug'): ?>
<script src="<?=$this->asset('/js/vendor/ZeroClipboard.min.js')?>"></script>
<?php endif ?>
<?php if ($this->section == 'index'): ?>
<script src="<?=$this->asset('/js/vendor/jquery.plugin.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/jquery.countdown.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/jquery.knob.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/bootstrap-contextmenu.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/jquery.scrollTo.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/Sortable.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/fastclick.min.js')?>"></script>
<?php else: ?>
<script src="<?=$this->asset('/js/vendor/bootstrap-select.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/parsley.min.js')?>"></script>
<?php endif ?>
<script src="<?=$this->asset('/js/runeui.min.js')?>"></script>
<?php if (is_localhost()): ?>
    <script src="<?=$this->asset('/js/vendor/jquery.onScreenKeyboard.js')?>"></script>
<?php endif ?>
<script src="<?=$this->asset('/js/vendor/pnotify.custom.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/modernizr-2.6.2-respond-1.1.0.min.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/openwebapp.js')?>"></script>

<script src="<?=$this->asset('/js/vendor/pnotify3.custom.min.js')?>"></script>
<script src="<?=$this->asset('/js/custom.js')?>"></script>
<script src="<?=$this->asset('/js/vendor/hammer.min.js')?>"></script>
<script src="<?=$this->asset('/js/gpio.js')?>"></script>
