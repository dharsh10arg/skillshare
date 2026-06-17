<?php

use Illuminate\Support\Facades\Artisan;

Artisan::command('skillsphere:about', function () {
    $this->info('SkillSphere API is ready.');
});

